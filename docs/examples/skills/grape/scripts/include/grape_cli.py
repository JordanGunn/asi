#!/usr/bin/env python3

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterable

def find_git_root(start: Path) -> Path | None:
    p = start.resolve()
    for parent in [p] + list(p.parents):
        if (parent / ".git").exists():
            return parent
    return None


INVOCATION_CWD = Path.cwd().resolve()
SKILL_REPO_ROOT = find_git_root(Path(__file__).resolve()) or INVOCATION_CWD


def _git_available(repo_root: Path | None) -> bool:
    return repo_root is not None and shutil.which("git") is not None


def _sha256_text(text: str) -> str:
    h = hashlib.sha256()
    h.update(text.encode("utf-8"))
    return h.hexdigest()


def _resolve_root(root: str) -> Path:
    p = Path(root)
    if p.is_absolute():
        return p.resolve()
    return (SKILL_REPO_ROOT / p).resolve()


def _posix_relpath(p: Path, root: Path) -> str:
    try:
        rel = p.resolve().relative_to(root.resolve())
        return rel.as_posix()
    except Exception:
        return p.as_posix()


def _display_path(p: Path) -> str:
    rel = _posix_relpath(p, SKILL_REPO_ROOT)
    return "." if rel == "." else rel


# Schema constants
INTENT_SCHEMA = "grape_intent_v1"
COMPILED_PLAN_SCHEMA = "grape_compiled_plan_v1"
SURFACE_PLAN_SCHEMA = "grape_surface_plan_v1"
INTENT_HASH_RE = re.compile(r"^sha256:[0-9a-f]{64}$")


def _normalize_json(obj: Any) -> str:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def _validate_compiled_plan(plan: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if not isinstance(plan, dict):
        return ["compiled plan must be a JSON object"]

    if plan.get("schema") != COMPILED_PLAN_SCHEMA:
        errors.append(f"schema must be {COMPILED_PLAN_SCHEMA}")

    intent = plan.get("intent")
    if not isinstance(intent, dict):
        errors.append("intent object missing or invalid")
    else:
        if intent.get("schema") != INTENT_SCHEMA:
            errors.append(f"intent.schema must be {INTENT_SCHEMA}")
        prompt = intent.get("prompt")
        if not isinstance(prompt, str) or not prompt.strip():
            errors.append("intent.prompt must be a non-empty string")

    intent_hash = plan.get("intent_hash")
    if not isinstance(intent_hash, str) or not INTENT_HASH_RE.match(intent_hash):
        errors.append("intent_hash must be sha256:<64 hex chars>")
    elif isinstance(intent, dict):
        normalized = _normalize_json(intent)
        computed = f"sha256:{_sha256_text(normalized)}"
        if intent_hash != computed:
            errors.append("intent_hash does not match computed sha256 of intent")

    grep = plan.get("grep")
    if not isinstance(grep, dict):
        errors.append("grep object missing or invalid")
        return errors

    if not isinstance(grep.get("root"), str) or not grep["root"]:
        errors.append("grep.root must be a non-empty string")

    patterns = grep.get("pattern")
    if not isinstance(patterns, list) or not patterns:
        errors.append("grep.pattern must be a non-empty array of strings")
    else:
        for p in patterns:
            if not isinstance(p, str) or not p:
                errors.append("each grep.pattern entry must be a non-empty string")
                break

    for field in ("glob", "exclude"):
        items = grep.get(field) or []
        if not isinstance(items, list):
            errors.append(f"grep.{field} must be an array of strings")
            continue
        for item in items:
            if not isinstance(item, str) or not item:
                errors.append(f"grep.{field} entries must be non-empty strings")
                break

    allowed_modes = {"fixed", "regex"}
    allowed_cases = {"sensitive", "insensitive", "smart"}
    allowed_formats = {"auto", "human", "jsonl"}
    allowed_strategies = {"single", "parallel", "cascade"}

    if grep.get("mode") not in allowed_modes:
        errors.append(f"grep.mode must be one of {sorted(allowed_modes)}")
    if grep.get("case") not in allowed_cases:
        errors.append(f"grep.case must be one of {sorted(allowed_cases)}")
    if grep.get("format") not in allowed_formats:
        errors.append(f"grep.format must be one of {sorted(allowed_formats)}")
    if grep.get("strategy") not in allowed_strategies:
        errors.append(f"grep.strategy must be one of {sorted(allowed_strategies)}")

    def _check_int(name: str, minimum: int, maximum: int | None = None) -> None:
        value = grep.get(name)
        if not isinstance(value, int):
            errors.append(f"grep.{name} must be an integer")
            return
        if value < minimum:
            errors.append(f"grep.{name} must be >= {minimum}")
        if maximum is not None and value > maximum:
            errors.append(f"grep.{name} must be <= {maximum}")

    _check_int("context", 0, 10)
    _check_int("max_lines", 0)
    _check_int("max_probes", 1)
    _check_int("max_derived", 0)
    _check_int("snapshot_max_files", 1000)

    policy = grep.get("policy")
    if not isinstance(policy, dict):
        errors.append("grep.policy is required")
    else:
        if not isinstance(policy.get("hidden"), bool):
            errors.append("grep.policy.hidden must be boolean")
        if not isinstance(policy.get("follow"), bool):
            errors.append("grep.policy.follow must be boolean")
        ignore = policy.get("ignore")
        if not isinstance(ignore, dict):
            errors.append("grep.policy.ignore must be an object")
        else:
            for bool_field in ("no_ignore", "no_ignore_vcs", "no_ignore_global"):
                if not isinstance(ignore.get(bool_field), bool):
                    errors.append(f"grep.policy.ignore.{bool_field} must be boolean")

    return errors


def _namespace_from_plan(plan: dict[str, Any]) -> argparse.Namespace:
    grep = plan["grep"]
    policy = grep["policy"]
    ignore = policy["ignore"]
    return argparse.Namespace(
        root=grep["root"],
        pattern=list(grep.get("pattern") or []),
        glob=list(grep.get("glob") or []),
        exclude=list(grep.get("exclude") or []),
        mode=grep["mode"],
        case=grep["case"],
        format=grep["format"],
        context=grep["context"],
        max_lines=grep["max_lines"],
        strategy=grep["strategy"],
        max_probes=grep["max_probes"],
        max_derived=grep["max_derived"],
        snapshot_max_files=grep["snapshot_max_files"],
        hidden=policy["hidden"],
        follow=policy["follow"],
        no_ignore=ignore["no_ignore"],
        no_ignore_vcs=ignore["no_ignore_vcs"],
        no_ignore_global=ignore["no_ignore_global"],
    )
# Canonical excludes must apply anywhere within the scanned tree.
CANONICAL_EXCLUDES: list[str] = [
    "**/.git/**",
    "**/node_modules/**",
    "**/dist/**",
    "**/build/**",
    "**/target/**",
    "**/.venv/**",
    "**/venv/**",
    "**/__pycache__/**",
    "**/.pytest_cache/**",
    "**/.mypy_cache/**",
    "**/.ruff_cache/**",
    "**/.idea/**",
    "**/.vscode/**",
]


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """grape - AI-enabled deterministic grep (parameterized by agent judgment)

Commands:
  help                         Show this help message
  validate                      Verify the skill is runnable (read-only)
  grep [opts]                   Run a deterministic surface search
  plan --plan <path>            Validate a compiled plan and run grep
  plan --stdin                  Validate a compiled plan from stdin and run grep

Output contract (grep):
  Always produces:
    1) Surface snapshot (bounded, deterministic)
    2) Search plan (schema-shaped)
    3) Results (hits or explicit absence)
    4) Probe ledger (auditable)
    5) Next-step suggestion (single axis)

Options (grep):
  --root <path>                 default: .
  --pattern <text>              repeatable (search terms)
  --glob <pattern>              repeatable (rg -g include glob)
  --exclude <pattern>           repeatable (rg -g '!pat' exclude glob)
  --mode <fixed|regex>          default: fixed
  --case <sensitive|insensitive|smart>  default: smart
  --format <auto|human|jsonl>   default: auto
  --context <n>                 default: 0
  --max-lines <n>               default: 500 (caps printed hit records)
  --strategy <single|parallel|cascade>  default: single
  --max-probes <n>              default: 8 (parallel probe cap)
  --max-derived <n>             default: 12 (cascade derived-term cap)
  --snapshot-max-files <n>      default: 20000 (surface snapshot cap)

Policy options (grep):
  --hidden                      search hidden files/dirs
  --follow                      follow symlinks
  --no-ignore                   do not respect ignore files (.gitignore/.ignore/etc)
  --no-ignore-vcs               do not respect VCS ignore (.gitignore)
  --no-ignore-global            do not respect global ignore

Usage:
  grape grep --root . --pattern "foo" --glob "src/**/*.py" --strategy single --format human
  grape grep --root . --pattern "foo" --pattern "bar" --strategy parallel --format jsonl
  grape grep --root . --pattern "foo" --strategy cascade --format auto
"""
    )
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    errors: list[str] = []

    if shutil.which("rg") is None:
        errors.append("missing command: rg (ripgrep)")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    print("ok: grape CLI is runnable")
    return 0


def _walk_files(root_path: Path, max_files: int) -> tuple[list[str], bool]:
    pruned_dir_names = {
        ".git",
        "node_modules",
        "dist",
        "build",
        "target",
        ".venv",
        "venv",
        "__pycache__",
        ".pytest_cache",
        ".mypy_cache",
        ".ruff_cache",
        ".idea",
        ".vscode",
    }

    collected: list[str] = []
    truncated = False

    for dirpath, dirnames, filenames in os.walk(root_path):
        dirnames.sort()
        dirnames[:] = [d for d in dirnames if d not in pruned_dir_names]
        filenames.sort()

        base = Path(dirpath)
        for fn in filenames:
            p = base / fn
            if not p.is_file():
                continue
            collected.append(_posix_relpath(p, root_path))
            if max_files >= 0 and len(collected) >= max_files:
                truncated = True
                return collected, truncated

    return collected, truncated


def _matches_any_glob(rel_posix: str, globs: list[str]) -> bool:
    if not globs:
        return False
    if rel_posix.startswith("./"):
        rel_posix = rel_posix[2:]
    from pathlib import PurePosixPath

    pp = PurePosixPath(rel_posix)
    for g in globs:
        if g.startswith("./"):
            g = g[2:]
        if pp.match(g):
            return True
    return False


def _in_scope(rel_posix: str, include_globs: list[str], exclude_globs: list[str]) -> bool:
    if exclude_globs and _matches_any_glob(rel_posix, exclude_globs):
        return False
    if include_globs and not _matches_any_glob(rel_posix, include_globs):
        return False
    return True


def _apply_scope_filters(
    rel_paths: Iterable[str],
    include_globs: list[str],
    exclude_globs: list[str],
) -> list[str]:
    return [rp for rp in rel_paths if _in_scope(rp, include_globs, exclude_globs)]


def _rg_files_argv(
    *,
    include_globs: list[str],
    exclude_globs: list[str],
    search_hidden: bool,
    follow_symlinks: bool,
    no_ignore: bool,
    no_ignore_vcs: bool,
    no_ignore_global: bool,
) -> list[str]:
    argv: list[str] = ["rg", "--files"]

    if search_hidden:
        argv.append("--hidden")
    if follow_symlinks:
        argv.append("--follow")
    if no_ignore:
        argv.append("--no-ignore")
    if no_ignore_vcs:
        argv.append("--no-ignore-vcs")
    if no_ignore_global:
        argv.append("--no-ignore-global")

    for g in include_globs:
        argv.extend(["-g", g])
    for e in exclude_globs:
        argv.extend(["-g", f"!{e}"])

    return argv


def _rg_list_files(
    *,
    root_path: Path,
    include_globs: list[str],
    exclude_globs: list[str],
    snapshot_max_files: int,
    search_hidden: bool,
    follow_symlinks: bool,
    no_ignore: bool,
    no_ignore_vcs: bool,
    no_ignore_global: bool,
) -> tuple[list[str], bool, str]:
    argv = _rg_files_argv(
        include_globs=include_globs,
        exclude_globs=exclude_globs,
        search_hidden=search_hidden,
        follow_symlinks=follow_symlinks,
        no_ignore=no_ignore,
        no_ignore_vcs=no_ignore_vcs,
        no_ignore_global=no_ignore_global,
    )

    try:
        r = subprocess.run(argv + ["."], cwd=str(root_path), check=False, capture_output=True, text=True)
    except OSError as e:
        raise RuntimeError(f"failed to run rg --files: {e}")

    # `rg --files` returns exit=1 when nothing matched; treat that as an empty, successful listing.
    if r.returncode not in (0, 1):
        msg = r.stderr.strip() if r.stderr else f"rg --files exited with status {r.returncode}"
        raise RuntimeError(msg)

    rel_paths = [ln.strip() for ln in r.stdout.splitlines() if ln.strip()]
    rel_paths = [p[2:] if p.startswith("./") else p for p in rel_paths]
    rel_paths.sort()

    truncated = False
    if snapshot_max_files >= 0 and len(rel_paths) > snapshot_max_files:
        rel_paths = rel_paths[:snapshot_max_files]
        truncated = True

    return rel_paths, truncated, "rg --files"


def _git_head_and_dirty(repo_root: Path) -> tuple[str | None, bool | None]:
    head: str | None = None
    dirty: bool | None = None

    r_head = subprocess.run(
        ["git", "-C", str(repo_root), "rev-parse", "HEAD"],
        check=False,
        capture_output=True,
        text=True,
    )
    if r_head.returncode == 0:
        head = r_head.stdout.strip() or None

    r_dirty = subprocess.run(
        ["git", "-C", str(repo_root), "status", "--porcelain"],
        check=False,
        capture_output=True,
        text=True,
    )
    if r_dirty.returncode == 0:
        dirty = bool(r_dirty.stdout.strip())

    return head, dirty


def _git_recent_paths(repo_root: Path, max_commits: int, max_paths: int) -> list[str]:
    r = subprocess.run(
        ["git", "-C", str(repo_root), "log", f"-n{max_commits}", "--name-only", "--pretty=format:"],
        check=False,
        capture_output=True,
        text=True,
    )
    if r.returncode != 0 or not r.stdout:
        return []
    paths = [ln.strip() for ln in r.stdout.splitlines() if ln.strip()]
    if max_paths >= 0 and len(paths) > max_paths:
        paths = paths[:max_paths]
    return paths


def _surface_snapshot(
    *,
    root_input: str,
    root_path: Path,
    include_globs: list[str],
    exclude_globs_user: list[str],
    snapshot_max_files: int,
    policies: dict[str, Any],
) -> dict[str, Any]:
    repo_root = find_git_root(root_path)
    vcs_available = _git_available(repo_root)
    vcs_used = vcs_available

    exclude_all = sorted(set(CANONICAL_EXCLUDES + exclude_globs_user))

    listing_error: str | None = None
    listing_used_tool: str = "rg --files"

    try:
        rel_paths, truncated, listing_used_tool = _rg_list_files(
            root_path=root_path,
            include_globs=include_globs,
            exclude_globs=exclude_all,
            snapshot_max_files=snapshot_max_files,
            search_hidden=bool(policies["hidden"]["search_hidden"]),
            follow_symlinks=bool(policies["follow_symlinks"]["enabled"]),
            no_ignore=bool(policies["ignore_files"]["no_ignore"]),
            no_ignore_vcs=bool(policies["ignore_files"]["no_ignore_vcs"]),
            no_ignore_global=bool(policies["ignore_files"]["no_ignore_global"]),
        )
    except RuntimeError as e:
        listing_error = str(e)
        listing_used_tool = "walk_fallback"
        walked, _ = _walk_files(root_path, -1)
        walked = _apply_scope_filters(walked, include_globs, exclude_all)
        walked.sort()
        truncated = False
        if snapshot_max_files >= 0 and len(walked) > snapshot_max_files:
            walked = walked[:snapshot_max_files]
            truncated = True
        rel_paths = walked

    ext_counts: dict[str, int] = {}
    top_dir_counts: dict[str, int] = {}
    for rp in rel_paths:
        ext = Path(rp).suffix.lower()
        ext_key = ext if ext else "<none>"
        ext_counts[ext_key] = ext_counts.get(ext_key, 0) + 1
        top = rp.split("/", 1)[0] if "/" in rp else "."
        top_dir_counts[top] = top_dir_counts.get(top, 0) + 1

    ext_hist = sorted(
        [{"ext": k, "count": v} for k, v in ext_counts.items()],
        key=lambda d: (-d["count"], d["ext"]),
    )[:10]
    top_dirs = sorted(
        [{"dir": k, "file_count": v} for k, v in top_dir_counts.items()],
        key=lambda d: (-d["file_count"], d["dir"]),
    )[:15]

    head, dirty = _git_head_and_dirty(repo_root) if vcs_available and repo_root is not None else (None, None)
    if vcs_available and head:
        marker: dict[str, Any] = {"kind": "git", "head": head, "dirty": dirty}
    else:
        marker = {"kind": "paths_sha256", "sha256": _sha256_text("\n".join(rel_paths))}

    recent_hotspots: list[dict[str, Any]] | None = None
    if vcs_used and repo_root is not None:
        recent_paths = _git_recent_paths(repo_root, max_commits=30, max_paths=2000)
        root_rel = _posix_relpath(root_path, repo_root).rstrip("/")
        if root_rel == ".":
            root_rel = ""
        hotspot_counts: dict[str, int] = {}
        for p in recent_paths:
            if root_rel and not (p == root_rel or p.startswith(root_rel + "/")):
                continue
            rp = p[len(root_rel) + 1 :] if root_rel else p
            if not rp or rp.endswith("/"):
                continue
            if not _in_scope(rp, include_globs, exclude_all):
                continue
            top = rp.split("/", 1)[0] if "/" in rp else "."
            hotspot_counts[top] = hotspot_counts.get(top, 0) + 1
        recent_hotspots = sorted(
            [{"dir": k, "touched_files": v} for k, v in hotspot_counts.items()],
            key=lambda d: (-d["touched_files"], d["dir"]),
        )[:10]

    return {
        "schema": "surface_snapshot_v1",
        "root": {"input": root_input, "resolved": _display_path(root_path)},
        "scope": {
            "include_globs": include_globs,
            "exclude_globs": exclude_all,
            "canonical_excludes": CANONICAL_EXCLUDES,
            "snapshot_max_files": snapshot_max_files,
        },
        "listing": {
            "requested_tool": "rg --files",
            "used_tool": listing_used_tool,
            "ok": listing_error is None,
            "error": listing_error,
        },
        "vcs": {"available": vcs_available, "used": vcs_used},
        "marker": marker,
        "file_count": len(rel_paths),
        "truncated": truncated,
        "dominant_extensions": ext_hist,
        "top_level_dirs": top_dirs,
        "recent_change_hotspots": recent_hotspots,
    }


def _probe_arglist(
    *,
    patterns: list[str],
    globs: list[str],
    excludes: list[str],
    mode: str,
    case: str,
    context: int,
    policies: dict[str, Any],
) -> list[str]:
    argv: list[str] = [
        "rg",
        "--json",
        "--sort",
        "path",
    ]

    if policies["hidden"]["search_hidden"]:
        argv.append("--hidden")
    if policies["follow_symlinks"]["enabled"]:
        argv.append("--follow")

    if policies["ignore_files"]["no_ignore"]:
        argv.append("--no-ignore")
    if policies["ignore_files"]["no_ignore_vcs"]:
        argv.append("--no-ignore-vcs")
    if policies["ignore_files"]["no_ignore_global"]:
        argv.append("--no-ignore-global")

    if mode == "fixed":
        argv.append("-F")

    if case == "insensitive":
        argv.append("-i")
    elif case == "smart":
        argv.append("-S")

    if context and context > 0:
        argv.extend(["-C", str(context)])

    for g in globs:
        argv.extend(["-g", g])
    for e in excludes:
        argv.extend(["-g", f"!{e}"])

    for p in patterns:
        argv.extend(["-e", p])

    argv.append(".")
    return argv


def _parse_rg_json_lines(stdout: str) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    hits: list[dict[str, Any]] = []
    summaries: list[dict[str, Any]] = []

    for ln in stdout.splitlines():
        ln = ln.strip()
        if not ln:
            continue
        try:
            ev = json.loads(ln)
        except json.JSONDecodeError:
            continue

        ev_type = ev.get("type")
        if ev_type == "match":
            data = ev.get("data") or {}
            path = ((data.get("path") or {}).get("text")) or ""
            line_no = data.get("line_number")
            lines = (data.get("lines") or {}).get("text") or ""
            snippet = lines.rstrip("\n")
            if path and isinstance(line_no, int):
                hits.append({"path": path, "line": line_no, "snippet": snippet})
        elif ev_type == "summary":
            summaries.append(ev.get("data") or {})

    return hits, summaries


def _rg_search_counts(summaries: list[dict[str, Any]]) -> tuple[int | None, int | None]:
    if not summaries:
        return None, None

    searches: int | None = None
    searches_with_match: int | None = None

    for s in summaries:
        stats = s.get("stats") or {}
        s_searches = stats.get("searches")
        s_swm = stats.get("searches_with_match")
        if isinstance(s_searches, int):
            searches = s_searches if searches is None else max(searches, s_searches)
        if isinstance(s_swm, int):
            searches_with_match = s_swm if searches_with_match is None else max(searches_with_match, s_swm)

    return searches, searches_with_match


def _derive_terms_from_hits(
    *,
    hits: list[dict[str, Any]],
    base_terms: list[str],
    max_derived: int,
) -> tuple[list[str], list[dict[str, Any]]]:
    import re

    stopwords = {
        "the",
        "and",
        "or",
        "for",
        "with",
        "from",
        "this",
        "that",
        "true",
        "false",
        "null",
        "none",
        "return",
        "class",
        "def",
        "function",
        "const",
        "let",
        "var",
        "public",
        "private",
        "protected",
        "static",
        "async",
        "await",
        "import",
        "export",
    }

    base_lower = {t.lower() for t in base_terms}

    token_re = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
    counts: dict[str, int] = {}
    doc_counts: dict[str, int] = {}
    display_tokens: dict[str, str] = {}
    samples: dict[str, dict[str, Any]] = {}

    min_evidence_count_plain = 3
    min_evidence_count_identifier = 2
    max_doc_ratio = 0.85

    def _is_identifier_like(token: str) -> bool:
        if "_" in token:
            return True
        has_lower = any(c.islower() for c in token)
        has_internal_upper = any(c.isupper() for c in token[1:])
        return has_lower and has_internal_upper

    total_docs = max(1, len(hits))

    for h in hits:
        snippet = str(h.get("snippet") or "")
        snippet_for_tokens = snippet.replace("\\n", " ").replace("\\r", " ").replace("\\t", " ")
        path = str(h.get("path") or "")
        found_in_doc: set[str] = set()
        for tok in token_re.findall(snippet_for_tokens):
            tl = tok.lower()
            if tl in stopwords:
                continue
            if tl in base_lower:
                continue
            counts[tl] = counts.get(tl, 0) + 1
            found_in_doc.add(tl)
            if tl not in display_tokens:
                display_tokens[tl] = tok
            if tl not in samples:
                samples[tl] = {"token": tl, "sample_path": path, "sample_snippet": snippet[:200]}
        for tl in found_in_doc:
            doc_counts[tl] = doc_counts.get(tl, 0) + 1

    candidates: list[tuple[str, int, int, float]] = []
    for tl, cnt in counts.items():
        dc = doc_counts.get(tl, 0)
        ratio = dc / total_docs
        token_display = display_tokens.get(tl, tl)

        ident_like = _is_identifier_like(token_display)
        has_digit = any(c.isdigit() for c in token_display)
        if not ident_like and not has_digit:
            continue

        if ident_like:
            if cnt < min_evidence_count_identifier:
                continue
        else:
            if cnt < min_evidence_count_plain:
                continue

        if ratio > max_doc_ratio:
            continue

        candidates.append((tl, cnt, dc, ratio))

    candidates.sort(key=lambda t: (-t[1], -t[2], t[0]))
    derived_norm = [tl for tl, _, _, _ in candidates][: max_derived if max_derived >= 0 else len(candidates)]
    derived = [display_tokens.get(tl, tl) for tl in derived_norm]

    ledger: list[dict[str, Any]] = []
    for tl in derived_norm:
        entry: dict[str, Any] = {
            "token": display_tokens.get(tl, tl),
            "token_normalized": tl,
            "evidence_count": counts.get(tl, 0),
            "doc_count": doc_counts.get(tl, 0),
            "doc_ratio": round((doc_counts.get(tl, 0) / total_docs), 4),
            "filters": {
                "min_evidence_count_plain": min_evidence_count_plain,
                "min_evidence_count_identifier": min_evidence_count_identifier,
                "max_doc_ratio": max_doc_ratio,
                "require_identifier_like_or_digit": True,
            },
        }
        sample = samples.get(tl)
        if sample:
            entry["sample_path"] = sample.get("sample_path")
            entry["sample_snippet"] = sample.get("sample_snippet")
        ledger.append(entry)

    return derived, ledger


def _next_step_suggestion(*, plan: dict[str, Any], match_count: int) -> dict[str, Any]:
    if match_count > 0:
        return {"action": "read_next", "note": "Pick 1-2 high-signal files from hits and read narrowly."}

    include_globs = ((plan.get("scope") or {}).get("include_globs")) or []
    mode = (plan.get("match") or {}).get("mode")
    case = (plan.get("match") or {}).get("case")

    if include_globs:
        return {"action": "widen", "axis": "include_globs", "note": "Remove or relax include globs."}
    if mode == "fixed":
        return {"action": "widen", "axis": "mode", "note": "Retry with --mode regex (one pass)."}
    if case == "sensitive":
        return {"action": "widen", "axis": "case", "note": "Retry with --case smart."}
    return {"action": "widen", "axis": "terms", "note": "Add 1-2 synonyms (bounded) and rerun."}


def _print_jsonl(kind: str, data: Any) -> None:
    print(json.dumps({"kind": kind, "data": data}, sort_keys=True))


def _trim(s: str, n: int) -> str:
    if len(s) <= n:
        return s
    return s[: max(0, n - 1)] + "…"


def _print_human_snapshot(snapshot: dict[str, Any]) -> None:
    print("Surface Snapshot")
    print(f"- root: {snapshot['root']['resolved']}")
    marker = snapshot.get("marker") or {}
    if marker.get("kind") == "git":
        print(f"- marker: git head={marker.get('head')} dirty={marker.get('dirty')}")
    else:
        print(f"- marker: {marker.get('kind')} sha256={marker.get('sha256')}")
    listing = snapshot.get("listing") or {}
    print(f"- listing: {listing.get('used_tool')} ok={listing.get('ok')}")
    print(f"- scope_files: {snapshot.get('file_count')} truncated={snapshot.get('truncated')}")

    exts = snapshot.get("dominant_extensions") or []
    if exts:
        ext_str = ", ".join([f"{e['ext']}={e['count']}" for e in exts[:5]])
        print(f"- top_ext: {ext_str}")
    dirs = snapshot.get("top_level_dirs") or []
    if dirs:
        dir_str = ", ".join([f"{d['dir']}={d['file_count']}" for d in dirs[:5]])
        print(f"- top_dirs: {dir_str}")


def _print_human_plan(plan: dict[str, Any]) -> None:
    print("\nSearch Plan")
    print(f"- root: {plan['root']['resolved']}")
    print(f"- strategy: {plan['strategy']}")
    print(f"- terms: {', '.join(plan['terms']['base'])}")
    print(f"- include_globs: {plan['scope']['include_globs']}")
    print(f"- exclude_globs: {plan['scope']['exclude_globs']}")
    m = plan["match"]
    print(f"- match: mode={m['mode']} case={m['case']} context={m['context']}")
    b = plan["bounds"]
    print(f"- bounds: max_lines={b['max_output_hits']} max_probes={b['max_probes']} max_derived={b['max_derived']}")
    pol = plan.get("policies") or {}
    if pol:
        ig = pol.get("ignore_files") or {}
        hid = pol.get("hidden") or {}
        fol = pol.get("follow_symlinks") or {}
        print(
            "- policies:"
            f" hidden={hid.get('search_hidden')}"
            f" follow={fol.get('enabled')}"
            f" respect_ignore_files={ig.get('respect_ignore_files')}"
            f" respect_vcs_ignore={ig.get('respect_vcs_ignore')}"
            f" respect_global_ignore={ig.get('respect_global_ignore')}"
        )


def _print_human_results(
    *,
    results_summary: dict[str, Any],
    hits: list[dict[str, Any]],
    truncated: bool,
    probe_ledger: list[dict[str, Any]],
    derivation_ledger: list[dict[str, Any]] | None,
    next_step: dict[str, Any],
) -> None:
    print("\nResults")
    print(
        f"- matches: {results_summary.get('matches')} files_with_matches: {results_summary.get('files_with_matches')}"
        f" probes_run: {results_summary.get('probes_run')}"
    )
    print(
        f"- scope_files: {results_summary.get('scope_files')} scope_truncated: {results_summary.get('scope_truncated')}"
        f" output_truncated: {truncated}"
    )

    if results_summary.get("matches") == 0:
        print("- no matches")
    else:
        for h in hits:
            path = h.get("path")
            line = h.get("line")
            snippet = _trim(str(h.get("snippet") or ""), 180)
            print(f"- {path}:{line}: {snippet}")

    print("\nProbe Ledger")
    for p in probe_ledger:
        pid = p.get("probe_id")
        phase = p.get("phase")
        hit_count = p.get("hit_count")
        files_searched = p.get("files_searched")
        patterns = p.get("patterns") or []
        pat_str = ", ".join(patterns)
        print(f"- {pid} phase={phase} hits={hit_count} files_searched={files_searched} patterns=[{pat_str}]")

    if derivation_ledger is not None:
        print("\nDerivation Ledger")
        for e in derivation_ledger[:10]:
            print(
                f"- {e.get('token')} count={e.get('evidence_count')} docs={e.get('doc_count')} ratio={e.get('doc_ratio')}"
            )

    print("\nNext Step")
    if next_step.get("action") == "widen":
        print(f"- widen axis={next_step.get('axis')}: {next_step.get('note')}")
    else:
        print(f"- {next_step.get('action')}: {next_step.get('note')}")


def cmd_grep(args: argparse.Namespace) -> int:
    root = args.root
    patterns: list[str] = args.pattern or []
    globs: list[str] = args.glob or []
    excludes: list[str] = args.exclude or []
    mode = args.mode
    case = args.case
    context = args.context
    max_lines = args.max_lines
    strategy = args.strategy
    max_probes = args.max_probes
    max_derived = args.max_derived
    snapshot_max_files = args.snapshot_max_files
    format_requested = args.format
    stdout_isatty = sys.stdout.isatty()
    if format_requested == "auto":
        format_resolved = "human" if stdout_isatty else "jsonl"
    else:
        format_resolved = format_requested

    if not patterns:
        print("error: at least one --pattern is required", file=sys.stderr)
        return 2

    root_path = _resolve_root(root)
    if not root_path.exists() or not root_path.is_dir():
        print(f"error: root not found or not a directory: {root_path}", file=sys.stderr)
        return 2

    excludes_all = sorted(set(CANONICAL_EXCLUDES + excludes))

    policies: dict[str, Any] = {
        "ignore_files": {
            "respect_ignore_files": not bool(args.no_ignore),
            "respect_vcs_ignore": not bool(args.no_ignore or args.no_ignore_vcs),
            "respect_global_ignore": not bool(args.no_ignore or args.no_ignore_global),
            "no_ignore": bool(args.no_ignore),
            "no_ignore_vcs": bool(args.no_ignore_vcs),
            "no_ignore_global": bool(args.no_ignore_global),
            "enforced_by_argv": bool(args.no_ignore or args.no_ignore_vcs or args.no_ignore_global),
        },
        "hidden": {
            "search_hidden": bool(args.hidden),
            "enforced_by_argv": bool(args.hidden),
        },
        "follow_symlinks": {
            "enabled": bool(args.follow),
            "enforced_by_argv": bool(args.follow),
        },
    }

    snapshot = _surface_snapshot(
        root_input=root,
        root_path=root_path,
        include_globs=globs,
        exclude_globs_user=excludes,
        snapshot_max_files=snapshot_max_files,
        policies=policies,
    )

    plan: dict[str, Any] = {
        "schema": "search_plan_v1",
        "root": {"input": root, "resolved": _display_path(root_path)},
        "scope": {
            "include_globs": globs,
            "exclude_globs": excludes_all,
            "canonical_excludes": CANONICAL_EXCLUDES,
        },
        "policies": policies,
        "match": {"mode": mode, "case": case, "context": context},
        "terms": {"base": patterns, "derived": []},
        "strategy": strategy,
        "bounds": {
            "max_output_hits": max_lines,
            "max_probes": max_probes,
            "max_derived": max_derived,
        },
        "engine": {"tool": "rg", "format": "rg_json"},
        "output": {
            "format_requested": format_requested,
            "format_resolved": format_resolved,
            "stdout_isatty": stdout_isatty,
        },
    }

    if format_resolved == "jsonl":
        _print_jsonl("surface_snapshot", snapshot)
        _print_jsonl("search_plan", plan)
    else:
        _print_human_snapshot(snapshot)
        _print_human_plan(plan)

    def run_probe(probe_id: str, phase: int, probe_patterns: list[str]) -> dict[str, Any]:
        argv = _probe_arglist(
            patterns=probe_patterns,
            globs=globs,
            excludes=excludes_all,
            mode=mode,
            case=case,
            context=context,
            policies=policies,
        )
        probe_plan = {
            "id": probe_id,
            "phase": phase,
            "patterns": probe_patterns,
            "argv": argv,
            "cwd": _display_path(root_path),
        }

        try:
            r = subprocess.run(argv, cwd=str(root_path), check=False, capture_output=True, text=True)
        except OSError as e:
            return {"ok": False, "plan": probe_plan, "error": f"failed to run rg: {e}"}

        if r.returncode not in (0, 1):
            err = r.stderr.strip() if r.stderr else f"rg exited with status {r.returncode}"
            return {"ok": False, "plan": probe_plan, "error": err}

        hits, rg_summaries = _parse_rg_json_lines(r.stdout)
        searches, searches_with_match = _rg_search_counts(rg_summaries)
        for h in hits:
            h["probe_id"] = probe_id
            h["phase"] = phase

        return {
            "ok": True,
            "plan": probe_plan,
            "hits": hits,
            "counts": {"files_searched": searches, "files_with_match": searches_with_match},
            "stderr": r.stderr.strip() if r.stderr else "",
        }

    probes: list[tuple[str, int, list[str]]] = []
    if strategy == "single":
        probes = [("P1", 1, patterns)]
    elif strategy == "parallel":
        if max_probes >= 0 and len(patterns) > max_probes:
            grouped: list[list[str]] = []
            chunk = max(1, (len(patterns) + max_probes - 1) // max_probes)
            for i in range(0, len(patterns), chunk):
                grouped.append(patterns[i : i + chunk])
            grouped = grouped[:max_probes]
            probes = [(f"P{i+1}", 1, pats) for i, pats in enumerate(grouped)]
        else:
            probes = [(f"P{i+1}", 1, [p]) for i, p in enumerate(patterns)]
    elif strategy == "cascade":
        probes = [("P1", 1, patterns)]
    else:
        print(f"error: unknown strategy '{strategy}'", file=sys.stderr)
        return 2

    probe_results: list[dict[str, Any]] = []
    if len(probes) <= 1:
        pid, phase, pats = probes[0]
        probe_results = [run_probe(pid, phase, pats)]
    else:
        with concurrent.futures.ThreadPoolExecutor(max_workers=min(len(probes), 8)) as ex:
            futs = [ex.submit(run_probe, pid, phase, pats) for pid, phase, pats in probes]
            for fut in concurrent.futures.as_completed(futs):
                probe_results.append(fut.result())

    probe_results.sort(key=lambda r: (r.get("plan") or {}).get("id") or "")

    for pr in probe_results:
        if not pr.get("ok"):
            if format_resolved == "jsonl":
                _print_jsonl("probe_error", pr)
            else:
                print(f"probe error: {pr.get('error')}", file=sys.stderr)
            return 1

    all_hits: list[dict[str, Any]] = []
    probe_ledger: list[dict[str, Any]] = []

    for pr in probe_results:
        hits = pr.get("hits") or []
        all_hits.extend(hits)
        counts = pr.get("counts") or {}
        probe_ledger.append(
            {
                "probe_id": (pr.get("plan") or {}).get("id"),
                "phase": (pr.get("plan") or {}).get("phase"),
                "patterns": (pr.get("plan") or {}).get("patterns"),
                "hit_count": len(hits),
                "files_searched": counts.get("files_searched"),
                "files_with_match": counts.get("files_with_match"),
                "argv": (pr.get("plan") or {}).get("argv"),
                "cwd": (pr.get("plan") or {}).get("cwd"),
            }
        )

    derivation_ledger: list[dict[str, Any]] | None = None
    derived_terms: list[str] = []
    cascade_derivation_event: dict[str, Any] | None = None

    if strategy == "cascade" and all_hits:
        derived_terms, derivation_ledger = _derive_terms_from_hits(
            hits=all_hits,
            base_terms=patterns,
            max_derived=max_derived,
        )
        plan["terms"]["derived"] = derived_terms
        cascade_derivation_event = {"derived_terms": derived_terms, "ledger": derivation_ledger}

        if derived_terms:
            pr2 = run_probe("P2", 2, derived_terms)
            if not pr2.get("ok"):
                if format_resolved == "jsonl":
                    _print_jsonl("probe_error", pr2)
                else:
                    print(f"probe error: {pr2.get('error')}", file=sys.stderr)
                return 1

            hits2 = pr2.get("hits") or []
            all_hits.extend(hits2)
            counts2 = pr2.get("counts") or {}
            probe_ledger.append(
                {
                    "probe_id": (pr2.get("plan") or {}).get("id"),
                    "phase": (pr2.get("plan") or {}).get("phase"),
                    "patterns": (pr2.get("plan") or {}).get("patterns"),
                    "hit_count": len(hits2),
                    "files_searched": counts2.get("files_searched"),
                    "files_with_match": counts2.get("files_with_match"),
                    "argv": (pr2.get("plan") or {}).get("argv"),
                    "cwd": (pr2.get("plan") or {}).get("cwd"),
                }
            )

    all_hits.sort(key=lambda h: (h.get("path") or "", int(h.get("line") or 0), h.get("probe_id") or ""))

    total_hits = len(all_hits)
    output_truncated = False
    printed_hits = all_hits
    if max_lines is not None and max_lines >= 0 and len(printed_hits) > max_lines:
        printed_hits = printed_hits[:max_lines]
        output_truncated = True

    rg_files_searched = max(
        [p.get("files_searched") for p in probe_ledger if isinstance(p.get("files_searched"), int)] or [None]
    )

    results_summary = {
        "schema": "results_summary_v1",
        "matches": total_hits,
        "files_with_matches": len({h.get("path") for h in all_hits if h.get("path")}),
        "scope_files": snapshot.get("file_count"),
        "scope_truncated": snapshot.get("truncated"),
        "files_searched": rg_files_searched,
        "probes_run": len(probe_ledger),
        "truncated": output_truncated,
        "scope": {
            "root": {"input": root, "resolved": _display_path(root_path)},
            "include_globs": globs,
            "exclude_globs": excludes_all,
        },
    }

    next_step = _next_step_suggestion(plan=plan, match_count=total_hits)

    if format_resolved == "jsonl":
        if cascade_derivation_event is not None:
            _print_jsonl("cascade_derivation", cascade_derivation_event)
        _print_jsonl("results", results_summary)
        if total_hits == 0:
            _print_jsonl("no_matches", {"summary": results_summary})
        else:
            for h in printed_hits:
                _print_jsonl("hit", h)
        _print_jsonl("probe_ledger", {"schema": "probe_ledger_v1", "probes": probe_ledger})
        if derivation_ledger is not None:
            _print_jsonl("derivation_ledger", {"schema": "derivation_ledger_v1", "entries": derivation_ledger})
        _print_jsonl("next_step", next_step)
        return 0

    _print_human_results(
        results_summary=results_summary,
        hits=printed_hits,
        truncated=output_truncated,
        probe_ledger=probe_ledger,
        derivation_ledger=derivation_ledger,
        next_step=next_step,
    )
    return 0


def cmd_scan(args: argparse.Namespace) -> int:
    root = args.root
    globs: list[str] = args.glob or []
    excludes: list[str] = args.exclude or []
    snapshot_max_files = args.snapshot_max_files
    format_requested = args.format
    stdout_isatty = sys.stdout.isatty()
    if format_requested == "auto":
        format_resolved = "human" if stdout_isatty else "jsonl"
    else:
        format_resolved = format_requested

    root_path = _resolve_root(root)
    if not root_path.exists() or not root_path.is_dir():
        print(f"error: root not found or not a directory: {root_path}", file=sys.stderr)
        return 2

    policies: dict[str, Any] = {
        "ignore_files": {
            "respect_ignore_files": not bool(args.no_ignore),
            "respect_vcs_ignore": not bool(args.no_ignore or args.no_ignore_vcs),
            "respect_global_ignore": not bool(args.no_ignore or args.no_ignore_global),
            "no_ignore": bool(args.no_ignore),
            "no_ignore_vcs": bool(args.no_ignore_vcs),
            "no_ignore_global": bool(args.no_ignore_global),
            "enforced_by_argv": bool(args.no_ignore or args.no_ignore_vcs or args.no_ignore_global),
        },
        "hidden": {
            "search_hidden": bool(args.hidden),
            "enforced_by_argv": bool(args.hidden),
        },
        "follow_symlinks": {
            "enabled": bool(args.follow),
            "enforced_by_argv": bool(args.follow),
        },
    }

    snapshot = _surface_snapshot(
        root_input=root,
        root_path=root_path,
        include_globs=globs,
        exclude_globs_user=excludes,
        snapshot_max_files=snapshot_max_files,
        policies=policies,
    )

    plan = {
        "schema": SURFACE_PLAN_SCHEMA,
        "root": root,
        "include_globs": globs,
        "exclude_globs": excludes,
        "snapshot_max_files": snapshot_max_files,
        "policy": {
            "hidden": policies["hidden"]["search_hidden"],
            "follow": policies["follow_symlinks"]["enabled"],
            "ignore": {
                "no_ignore": policies["ignore_files"]["no_ignore"],
                "no_ignore_vcs": policies["ignore_files"]["no_ignore_vcs"],
                "no_ignore_global": policies["ignore_files"]["no_ignore_global"],
            },
        },
        "output": {
            "format_requested": format_requested,
            "format_resolved": format_resolved,
            "stdout_isatty": stdout_isatty,
        },
    }

    if format_resolved == "jsonl":
        _print_jsonl("surface_plan", plan)
        _print_jsonl("surface_snapshot", snapshot)
        return 0

    _print_human_snapshot(snapshot)
    return 0


def cmd_plan(args: argparse.Namespace) -> int:
    use_stdin = bool(args.stdin)
    plan_arg = args.plan

    if use_stdin and plan_arg:
        print("error: use either --plan or --stdin, not both", file=sys.stderr)
        return 2
    if not use_stdin and not plan_arg:
        print("error: --plan is required unless --stdin is used", file=sys.stderr)
        return 2

    try:
        if use_stdin:
            raw = sys.stdin.read()
            if not raw.strip():
                print("error: stdin plan is empty", file=sys.stderr)
                return 2
            plan_data = json.loads(raw)
        else:
            plan_path = Path(plan_arg)
            if not plan_path.exists():
                print(f"error: plan file not found: {plan_path}", file=sys.stderr)
                return 2
            plan_data = json.loads(plan_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"error: invalid JSON in plan: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"error: failed to read plan: {exc}", file=sys.stderr)
        return 2

    errors = _validate_compiled_plan(plan_data)
    if errors:
        for err in errors:
            print(f"error: {err}", file=sys.stderr)
        return 2

    _print_jsonl("compiled_plan", plan_data)
    plan_args = _namespace_from_plan(plan_data)
    return cmd_grep(plan_args)


def main() -> int:
    parser = argparse.ArgumentParser(prog="grape", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_scan = sub.add_parser("scan")
    p_scan.add_argument("--root", default=".")
    p_scan.add_argument("--glob", action="append")
    p_scan.add_argument("--exclude", action="append")
    p_scan.add_argument("--format", choices=["auto", "human", "jsonl"], default="auto")
    p_scan.add_argument("--snapshot-max-files", type=int, default=20000)
    p_scan.add_argument("--hidden", action="store_true")
    p_scan.add_argument("--follow", action="store_true")
    p_scan.add_argument("--no-ignore", action="store_true")
    p_scan.add_argument("--no-ignore-vcs", action="store_true")
    p_scan.add_argument("--no-ignore-global", action="store_true")

    p_grep = sub.add_parser("grep")
    p_grep.add_argument("--root", default=".")
    p_grep.add_argument("--pattern", action="append")
    p_grep.add_argument("--glob", action="append")
    p_grep.add_argument("--exclude", action="append")
    p_grep.add_argument("--mode", choices=["fixed", "regex"], default="fixed")
    p_grep.add_argument("--case", choices=["sensitive", "insensitive", "smart"], default="smart")
    p_grep.add_argument("--format", choices=["auto", "human", "jsonl"], default="auto")
    p_grep.add_argument("--context", type=int, default=0)
    p_grep.add_argument("--max-lines", type=int, default=500)
    p_grep.add_argument("--strategy", choices=["single", "parallel", "cascade"], default="single")
    p_grep.add_argument("--max-probes", type=int, default=8)
    p_grep.add_argument("--max-derived", type=int, default=12)
    p_grep.add_argument("--snapshot-max-files", type=int, default=20000)

    p_grep.add_argument("--hidden", action="store_true")
    p_grep.add_argument("--follow", action="store_true")
    p_grep.add_argument("--no-ignore", action="store_true")
    p_grep.add_argument("--no-ignore-vcs", action="store_true")
    p_grep.add_argument("--no-ignore-global", action="store_true")

    p_plan = sub.add_parser("plan")
    p_plan.add_argument("--plan")
    p_plan.add_argument("--stdin", action="store_true")

    args = parser.parse_args()
    cmd = args.command or "help"

    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "scan":
        return cmd_scan(args)
    if cmd == "plan":
        return cmd_plan(args)
    if cmd == "grep":
        return cmd_grep(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
