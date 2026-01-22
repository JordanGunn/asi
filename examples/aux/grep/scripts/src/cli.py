#!/usr/bin/env python3
"""
aux/grep CLI - Agent-assisted text search (deterministic ripgrep wrapper)

All execution is deterministic. The agent selects parameters; this script executes.
"""

import argparse
import hashlib
import json
import platform
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


def _get_tool_versions() -> dict:
    """Get tool versions for reproducibility metadata."""
    versions = {"python": platform.python_version()}
    try:
        r = subprocess.run(["rg", "--version"], capture_output=True, text=True, check=False)
        if r.returncode == 0:
            first_line = r.stdout.strip().split("\n")[0]
            versions["rg"] = first_line
    except OSError:
        versions["rg"] = "not found"
    return versions


def _compute_query_id(param_block: dict) -> str:
    """Compute stable query_id from normalized parameters."""
    keys_for_hash = ["root", "patterns", "globs", "excludes", "mode", "case", "context"]
    hashable = {k: param_block.get(k) for k in keys_for_hash if k in param_block}
    normalized = json.dumps(hashable, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    h = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    return f"sha256:{h}"


def _emit_jsonl(obj: dict) -> None:
    """Emit a single JSONL record."""
    print(json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False))


def _resolve_root(root: str) -> Path:
    """Resolve root path to absolute."""
    p = Path(root)
    return p.resolve()


def _build_rg_args(
    root: Path,
    pattern: str,
    globs: list[str],
    excludes: list[str],
    mode: str,
    case: str,
    context: int,
    hidden: bool,
    follow: bool,
    no_ignore: bool,
) -> list[str]:
    """Build ripgrep argument list."""
    args = ["rg", "--line-number", "--with-filename"]

    if mode == "fixed":
        args.append("--fixed-strings")

    if case == "sensitive":
        args.append("--case-sensitive")
    elif case == "insensitive":
        args.append("--ignore-case")
    # smart is rg default

    if context > 0:
        args.extend(["--context", str(context)])

    if hidden:
        args.append("--hidden")

    if follow:
        args.append("--follow")

    if no_ignore:
        args.append("--no-ignore")

    for g in sorted(globs):
        args.extend(["--glob", g])

    for e in sorted(excludes):
        args.extend(["--glob", f"!{e}"])

    args.append("--")
    args.append(pattern)
    args.append(str(root))

    return args


def _run_single_search(
    root: Path,
    pattern: str,
    globs: list[str],
    excludes: list[str],
    mode: str,
    case: str,
    context: int,
    hidden: bool,
    follow: bool,
    no_ignore: bool,
) -> tuple[str, list[str], int]:
    """Run a single rg search and return (pattern, lines, return_code)."""
    args = _build_rg_args(root, pattern, globs, excludes, mode, case, context, hidden, follow, no_ignore)

    try:
        result = subprocess.run(args, capture_output=True, text=True, check=False)
        lines = result.stdout.strip().split("\n") if result.stdout.strip() else []
        return pattern, lines, result.returncode
    except OSError as e:
        return pattern, [f"error: {e}"], 1


def cmd_run(args: argparse.Namespace) -> int:
    """Execute the grep search."""
    root = _resolve_root(args.root)
    patterns: list[str] = args.pattern or []
    globs: list[str] = sorted(args.glob or [])
    excludes: list[str] = sorted(args.exclude or [])
    mode: str = args.mode
    case: str = args.case
    context: int = args.context
    output_format: str = args.format
    max_lines: int = args.max_lines
    max_files: int | None = args.max_files
    max_matches: int | None = args.max_matches
    parallelism: int = args.parallelism
    hidden: bool = args.hidden
    follow: bool = args.follow
    no_ignore: bool = args.no_ignore

    if not patterns:
        print("error: at least one --pattern is required", file=sys.stderr)
        return 1

    if not root.exists():
        print(f"error: root directory not found: {root}", file=sys.stderr)
        return 1

    # Build param block for reproducibility
    param_block = {
        "root": str(root),
        "patterns": sorted(patterns),
        "globs": globs,
        "excludes": excludes,
        "mode": mode,
        "case": case,
        "context": context,
        "format": output_format,
        "max_lines": max_lines,
        "max_files": max_files,
        "max_matches": max_matches,
        "parallelism": parallelism,
        "policy": {
            "hidden": hidden,
            "follow": follow,
            "no_ignore": no_ignore,
        },
    }
    param_block["query_id"] = _compute_query_id(param_block)

    # Detect output format
    is_tty = sys.stdout.isatty()
    effective_format = output_format if output_format != "auto" else ("human" if is_tty else "jsonl")

    # Emit param block
    if effective_format == "jsonl":
        _emit_jsonl({"kind": "param_block", "param_block": param_block})
    else:
        print(f"# query_id: {param_block['query_id']}")
        print(f"# root: {root}")
        print(f"# patterns: {patterns}")
        print(f"# globs: {globs}")
        print(f"# excludes: {excludes}")
        print()

    # Run searches in parallel
    all_lines: list[str] = []
    files_seen: set[str] = set()

    with ThreadPoolExecutor(max_workers=parallelism) as executor:
        futures = {
            executor.submit(
                _run_single_search,
                root, p, globs, excludes, mode, case, context, hidden, follow, no_ignore
            ): p
            for p in patterns
        }

        for future in as_completed(futures):
            pattern, lines, _ = future.result()
            for line in lines:
                if line and ":" in line:
                    parts = line.split(":", 2)
                    if len(parts) >= 2:
                        files_seen.add(parts[0])
                all_lines.append(line)

    # Sort and apply caps
    all_lines.sort()

    total_matches = len(all_lines)
    total_files = len(files_seen)
    truncated = False

    if max_matches and len(all_lines) > max_matches:
        all_lines = all_lines[:max_matches]
        truncated = True

    if max_lines and len(all_lines) > max_lines:
        all_lines = all_lines[:max_lines]
        truncated = True

    # Emit results
    if effective_format == "jsonl":
        _emit_jsonl({
            "kind": "summary",
            "files": total_files,
            "matches": total_matches,
            "truncated": truncated,
        })
        for line in all_lines:
            if line:
                _emit_jsonl({"kind": "match", "line": line})
    else:
        print(f"files: {total_files}")
        print(f"matches: {total_matches}")
        if truncated:
            print("(truncated)")
        print()
        for line in all_lines:
            if line:
                print(line)

    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    """Verify the skill is runnable."""
    errors: list[str] = []

    if shutil.which("rg") is None:
        errors.append("missing command: rg (ripgrep)")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    print("ok: grep CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="aux/grep - Agent-assisted text search")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # validate
    subparsers.add_parser("validate", help="Verify the skill is runnable")

    # run
    run_parser = subparsers.add_parser("run", help="Execute a deterministic text search")
    run_parser.add_argument("--root", default=".", help="Root directory")
    run_parser.add_argument("--pattern", action="append", help="Search pattern (repeatable)")
    run_parser.add_argument("--glob", action="append", help="Include glob (repeatable)")
    run_parser.add_argument("--exclude", action="append", help="Exclude glob (repeatable)")
    run_parser.add_argument("--mode", choices=["fixed", "regex"], default="fixed")
    run_parser.add_argument("--case", choices=["sensitive", "insensitive", "smart"], default="smart")
    run_parser.add_argument("--context", type=int, default=0)
    run_parser.add_argument("--format", choices=["auto", "human", "jsonl"], default="auto")
    run_parser.add_argument("--max-lines", type=int, default=500)
    run_parser.add_argument("--max-files", type=int, default=None)
    run_parser.add_argument("--max-matches", type=int, default=None)
    run_parser.add_argument("--parallelism", type=int, default=4)
    run_parser.add_argument("--hidden", action="store_true")
    run_parser.add_argument("--follow", action="store_true")
    run_parser.add_argument("--no-ignore", action="store_true")
    run_parser.add_argument("--stdin", action="store_true", help="Read plan JSON from stdin")

    args = parser.parse_args()

    if args.command == "validate":
        return cmd_validate(args)
    elif args.command == "run":
        return cmd_run(args)

    return 1


if __name__ == "__main__":
    sys.exit(main())
