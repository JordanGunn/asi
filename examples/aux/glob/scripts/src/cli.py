#!/usr/bin/env python3
"""
aux/glob CLI - Agent-assisted file enumeration (deterministic fd wrapper)

All execution is deterministic. The agent selects parameters; this script executes.
"""

import argparse
import hashlib
import json
import platform
import shutil
import subprocess
import sys
from pathlib import Path


def _get_tool_versions() -> dict:
    """Get tool versions for reproducibility metadata."""
    versions = {"python": platform.python_version()}
    try:
        r = subprocess.run(["fd", "--version"], capture_output=True, text=True, check=False)
        if r.returncode == 0:
            versions["fd"] = r.stdout.strip()
    except OSError:
        versions["fd"] = "not found"
    return versions


def _compute_query_id(param_block: dict) -> str:
    """Compute stable query_id from normalized parameters."""
    keys_for_hash = ["root", "patterns", "extensions", "excludes", "type", "max_depth"]
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


def _build_fd_args(
    root: Path,
    patterns: list[str],
    extensions: list[str],
    excludes: list[str],
    entry_type: str,
    max_depth: int | None,
    hidden: bool,
    follow: bool,
    no_ignore: bool,
) -> list[str]:
    """Build fd argument list."""
    args = ["fd"]

    # Type filter
    if entry_type == "file":
        args.extend(["--type", "f"])
    elif entry_type == "directory":
        args.extend(["--type", "d"])
    # 'any' means no type filter

    if max_depth is not None:
        args.extend(["--max-depth", str(max_depth)])

    if hidden:
        args.append("--hidden")

    if follow:
        args.append("--follow")

    if no_ignore:
        args.append("--no-ignore")

    for ext in sorted(extensions):
        args.extend(["--extension", ext])

    for exc in sorted(excludes):
        args.extend(["--exclude", exc])

    # If patterns provided, use the first one as the search pattern
    # fd takes a single regex pattern, so we'll join with |
    if patterns:
        combined_pattern = "|".join(f"({p})" for p in sorted(patterns))
        args.append(combined_pattern)
    else:
        # Match everything
        args.append(".")

    args.append(str(root))

    return args


def cmd_run(args: argparse.Namespace) -> int:
    """Execute the glob enumeration."""
    root = _resolve_root(args.root)
    patterns: list[str] = sorted(args.pattern or [])
    extensions: list[str] = sorted(args.extension or [])
    excludes: list[str] = sorted(args.exclude or [])
    entry_type: str = args.type
    max_depth: int | None = args.max_depth
    max_results: int = args.max_results
    output_format: str = args.format
    hidden: bool = args.hidden
    follow: bool = args.follow
    no_ignore: bool = args.no_ignore

    if not root.exists():
        print(f"error: root directory not found: {root}", file=sys.stderr)
        return 1

    # Build param block for reproducibility
    param_block = {
        "root": str(root),
        "patterns": patterns,
        "extensions": extensions,
        "excludes": excludes,
        "type": entry_type,
        "max_depth": max_depth,
        "max_results": max_results,
        "format": output_format,
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
        print(f"# extensions: {extensions}")
        print(f"# excludes: {excludes}")
        print(f"# type: {entry_type}")
        print()

    # Build and run fd command
    fd_args = _build_fd_args(
        root, patterns, extensions, excludes, entry_type, max_depth, hidden, follow, no_ignore
    )

    try:
        result = subprocess.run(fd_args, capture_output=True, text=True, check=False)
        lines = result.stdout.strip().split("\n") if result.stdout.strip() else []
    except OSError as e:
        print(f"error: failed to run fd: {e}", file=sys.stderr)
        return 1

    # Sort and apply caps
    lines.sort()

    total_results = len(lines)
    truncated = False

    if len(lines) > max_results:
        lines = lines[:max_results]
        truncated = True

    # Count types
    file_count = 0
    dir_count = 0
    for line in lines:
        if line:
            p = Path(line)
            if p.is_dir():
                dir_count += 1
            else:
                file_count += 1

    # Emit results
    if effective_format == "jsonl":
        _emit_jsonl({
            "kind": "summary",
            "total": total_results,
            "files": file_count,
            "directories": dir_count,
            "truncated": truncated,
        })
        for line in lines:
            if line:
                entry_type_actual = "directory" if Path(line).is_dir() else "file"
                _emit_jsonl({"kind": "entry", "path": line, "type": entry_type_actual})
    else:
        print(f"total: {total_results}")
        print(f"files: {file_count}")
        print(f"directories: {dir_count}")
        if truncated:
            print("(truncated)")
        print()
        for line in lines:
            if line:
                print(line)

    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    """Verify the skill is runnable."""
    errors: list[str] = []

    if shutil.which("fd") is None:
        errors.append("missing command: fd (fd-find)")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    print("ok: glob CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="aux/glob - Agent-assisted file enumeration")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # validate
    subparsers.add_parser("validate", help="Verify the skill is runnable")

    # run
    run_parser = subparsers.add_parser("run", help="Execute a deterministic file enumeration")
    run_parser.add_argument("--root", default=".", help="Root directory")
    run_parser.add_argument("--pattern", action="append", help="Glob pattern (repeatable)")
    run_parser.add_argument("--extension", action="append", help="File extension (repeatable)")
    run_parser.add_argument("--exclude", action="append", help="Exclude pattern (repeatable)")
    run_parser.add_argument("--type", choices=["file", "directory", "any"], default="file")
    run_parser.add_argument("--max-depth", type=int, default=None)
    run_parser.add_argument("--max-results", type=int, default=1000)
    run_parser.add_argument("--format", choices=["auto", "human", "jsonl"], default="auto")
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
