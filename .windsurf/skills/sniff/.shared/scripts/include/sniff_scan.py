from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from sniff_common import (
    Range,
    append_ledger,
    ensure_sniff_dir,
    git_ls_files,
    iter_ledger,
    latest_by_id,
    make_anchor,
    make_id,
    read_lines,
    utcnow_iso,
    write_index,
    write_state,
)


_DEFAULTS = {
    "bloaters": {
        "long_method_lines": 80,
        "long_param_commas": 6,
        "large_class_lines": 400,
    },
    "couplers": {
        "message_chain_depth": 4,
        "feature_envy_external_refs": 12,
    },
    "oo_abusers": {
        "switch_keyword_count": 10,
    },
    "preventers": {
        "git_commit_count": 60,
    },
}


_DEF_RE = re.compile(r"^\s*def\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(")
_CLASS_RE = re.compile(r"^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)\b")


def _python_block(lines: list[str], start: int) -> Range:
    base_indent = len(lines[start - 1]) - len(lines[start - 1].lstrip(" "))
    end = start
    for i in range(start, len(lines) + 1):
        line = lines[i - 1]
        if i == start:
            end = i
            continue
        if not line.strip():
            end = i
            continue
        indent = len(line) - len(line.lstrip(" "))
        if indent <= base_indent and not line.lstrip().startswith("#"):
            return Range(start=start, end=end)
        end = i
    return Range(start=start, end=end)


def _find_python_defs(lines: list[str]) -> list[Range]:
    out: list[Range] = []
    for i, line in enumerate(lines, start=1):
        if _DEF_RE.match(line):
            out.append(_python_block(lines, i))
    return out


def _find_python_classes(lines: list[str]) -> list[Range]:
    out: list[Range] = []
    for i, line in enumerate(lines, start=1):
        if _CLASS_RE.match(line):
            out.append(_python_block(lines, i))
    return out


def _count_commas_in_sig(line: str) -> int:
    # best-effort signature detection; count commas before any closing paren
    if "(" not in line:
        return 0
    frag = line.split("(", 1)[1]
    frag = frag.split(")", 1)[0]
    return frag.count(",")


_CHAIN_CALL_RE = re.compile(r"(\.[A-Za-z_][A-Za-z0-9_]*\s*\([^)]*\))+" )
_CHAIN_ATTR_RE = re.compile(r"(\.[A-Za-z_][A-Za-z0-9_]*){4,}")


def scan_group(repo_root: Path, group: str, *, thresholds: dict[str, Any] | None = None) -> int:
    if group not in _DEFAULTS:
        raise ValueError(f"unknown group: {group}")

    t = dict(_DEFAULTS[group])
    if thresholds:
        t.update({k: thresholds[k] for k in thresholds.keys() if k in t})

    sniff_dir = ensure_sniff_dir(repo_root)
    ledger_path = sniff_dir / "findings.jsonl"

    existing = latest_by_id([])
    if ledger_path.exists():
        existing = latest_by_id(iter_ledger(ledger_path))

    paths = git_ls_files(repo_root)
    created = 0
    now = utcnow_iso()

    for rel in paths:
        p = repo_root / rel
        if not p.is_file():
            continue
        try:
            lines = read_lines(p)
        except Exception:
            continue

        if group == "bloaters":
            created += _scan_bloaters(rel, lines, t, existing, ledger_path, now)
        elif group == "couplers":
            created += _scan_couplers(rel, lines, t, existing, ledger_path, now)
        elif group == "oo_abusers":
            created += _scan_oo_abusers(rel, lines, t, existing, ledger_path, now)
        elif group == "preventers":
            created += _scan_preventers(repo_root, rel, lines, t, existing, ledger_path, now)

    # regenerate index after scan
    latest = latest_by_id(iter_ledger(ledger_path))
    write_index(sniff_dir, latest)
    write_state(sniff_dir, {"version": "sniff:v1", "updated_at": now, "thresholds": {group: t}})
    return created


def _append_if_new(record: dict[str, Any], existing: dict[str, dict[str, Any]], ledger_path: Path) -> bool:
    rid = record["id"]
    if rid in existing:
        return False
    append_ledger(ledger_path, record)
    existing[rid] = record
    return True


def _scan_bloaters(rel: str, lines: list[str], t: dict[str, Any], existing: dict[str, dict[str, Any]], ledger_path: Path, now: str) -> int:
    created = 0

    for r in _find_python_defs(lines):
        span = r.end - r.start + 1
        if span >= int(t["long_method_lines"]):
            smell = "Long Method"
            anchor = make_anchor(lines, r)
            rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
            rec = {
                "id": rid,
                "smell": smell,
                "group": "bloaters",
                "path": rel,
                "range": {"start": r.start, "end": r.end},
                "anchor": anchor,
                "evidence": {"rule_id": "bloaters/long-method/heuristic-01", "metrics": {"lines": span}},
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
            if _append_if_new(rec, existing, ledger_path):
                created += 1

        sig_line = lines[r.start - 1]
        commas = _count_commas_in_sig(sig_line)
        if commas >= int(t["long_param_commas"]):
            smell = "Long Parameter List"
            anchor = make_anchor(lines, Range(start=r.start, end=r.start))
            rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
            rec = {
                "id": rid,
                "smell": smell,
                "group": "bloaters",
                "path": rel,
                "range": {"start": r.start, "end": r.start},
                "anchor": anchor,
                "evidence": {"rule_id": "bloaters/long-parameter-list/heuristic-01", "metrics": {"commas": commas}},
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
            if _append_if_new(rec, existing, ledger_path):
                created += 1

    for r in _find_python_classes(lines):
        span = r.end - r.start + 1
        if span >= int(t["large_class_lines"]):
            smell = "Large Class"
            anchor = make_anchor(lines, r)
            rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
            rec = {
                "id": rid,
                "smell": smell,
                "group": "bloaters",
                "path": rel,
                "range": {"start": r.start, "end": r.end},
                "anchor": anchor,
                "evidence": {"rule_id": "bloaters/large-class/heuristic-01", "metrics": {"lines": span}},
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
            if _append_if_new(rec, existing, ledger_path):
                created += 1

    return created


def _scan_couplers(rel: str, lines: list[str], t: dict[str, Any], existing: dict[str, dict[str, Any]], ledger_path: Path, now: str) -> int:
    created = 0

    depth_needed = int(t["message_chain_depth"])
    for i, line in enumerate(lines, start=1):
        m = _CHAIN_CALL_RE.search(line)
        if m:
            seg = m.group(0)
            depth = seg.count(".")
            if depth >= depth_needed:
                smell = "Message Chains"
                anchor = make_anchor(lines, Range(start=i, end=i))
                rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
                rec = {
                    "id": rid,
                    "smell": smell,
                    "group": "couplers",
                    "path": rel,
                    "range": {"start": i, "end": i},
                    "anchor": anchor,
                    "evidence": {"rule_id": "couplers/message-chains/heuristic-01", "metrics": {"depth": depth}},
                    "status": "active",
                    "created_at": now,
                    "updated_at": now,
                }
                if _append_if_new(rec, existing, ledger_path):
                    created += 1

        if _CHAIN_ATTR_RE.search(line):
            smell = "Message Chains"
            anchor = make_anchor(lines, Range(start=i, end=i))
            rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
            rec = {
                "id": rid,
                "smell": smell,
                "group": "couplers",
                "path": rel,
                "range": {"start": i, "end": i},
                "anchor": anchor,
                "evidence": {"rule_id": "couplers/message-chains/heuristic-02", "metrics": {}},
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
            if _append_if_new(rec, existing, ledger_path):
                created += 1

    # feature envy: python-only best-effort
    ext_needed = int(t["feature_envy_external_refs"])
    for r in _find_python_defs(lines):
        body = "".join(lines[r.start - 1 : r.end])
        # count external member access (name.) excluding self/this
        refs = re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\.", body)
        counts: dict[str, int] = {}
        for nm in refs:
            if nm in {"self", "this"}:
                continue
            counts[nm] = counts.get(nm, 0) + 1
        if not counts:
            continue
        top_name, top_count = max(counts.items(), key=lambda kv: kv[1])
        if top_count >= ext_needed:
            smell = "Feature Envy"
            anchor = make_anchor(lines, r)
            rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
            rec = {
                "id": rid,
                "smell": smell,
                "group": "couplers",
                "path": rel,
                "range": {"start": r.start, "end": r.end},
                "anchor": anchor,
                "evidence": {
                    "rule_id": "couplers/feature-envy/heuristic-01",
                    "metrics": {"external": top_name, "external_refs": top_count, "lines": r.end - r.start + 1},
                },
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
            if _append_if_new(rec, existing, ledger_path):
                created += 1

    return created


def _scan_oo_abusers(rel: str, lines: list[str], t: dict[str, Any], existing: dict[str, dict[str, Any]], ledger_path: Path, now: str) -> int:
    created = 0
    n = 0
    for line in lines:
        s = line.lower()
        if "switch" in s or "case" in s or re.search(r"\bmatch\b", s):
            n += 1
    if n >= int(t["switch_keyword_count"]):
        smell = "Switch Statements"
        anchor = make_anchor(lines, Range(start=1, end=min(len(lines), 5)))
        rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
        rec = {
            "id": rid,
            "smell": smell,
            "group": "oo_abusers",
            "path": rel,
            "range": {"start": 1, "end": min(len(lines), 5)},
            "anchor": anchor,
            "evidence": {"rule_id": "oo-abusers/switch-statements/heuristic-01", "metrics": {"keyword_hits": n}},
            "status": "active",
            "created_at": now,
            "updated_at": now,
        }
        if _append_if_new(rec, existing, ledger_path):
            created += 1

    return created


def _scan_preventers(repo_root: Path, rel: str, lines: list[str], t: dict[str, Any], existing: dict[str, dict[str, Any]], ledger_path: Path, now: str) -> int:
    # Minimal deterministic git-based heuristic: commit count for file.
    import subprocess

    created = 0
    proc = subprocess.run(
        ["git", "rev-list", "--count", "HEAD", "--", rel],
        cwd=str(repo_root),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode != 0:
        return 0
    try:
        count = int(proc.stdout.decode("utf-8", errors="replace").strip() or "0")
    except Exception:
        count = 0

    if count >= int(t["git_commit_count"]):
        smell = "Divergent Change"
        anchor = make_anchor(lines, Range(start=1, end=min(len(lines), 5)))
        rid = make_id(smell=smell, path=rel, core_hash=anchor["core_hash"])
        rec = {
            "id": rid,
            "smell": smell,
            "group": "preventers",
            "path": rel,
            "range": {"start": 1, "end": min(len(lines), 5)},
            "anchor": anchor,
            "evidence": {"rule_id": "preventers/divergent-change/heuristic-01", "metrics": {"commit_count": count}},
            "status": "active",
            "created_at": now,
            "updated_at": now,
        }
        if _append_if_new(rec, existing, ledger_path):
            created += 1

    return created
