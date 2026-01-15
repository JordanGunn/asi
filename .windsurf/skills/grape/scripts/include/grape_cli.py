#!/usr/bin/env python3

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def repo_root_from_file(file_path: Path) -> Path:
    p = file_path.resolve()
    for parent in [p] + list(p.parents):
        if (parent / ".git").exists():
            return parent
    return Path.cwd().resolve()


REPO_ROOT = repo_root_from_file(Path(__file__))


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """grape - AI-enabled deterministic grep (parameterized by agent judgment)\n\nCommands:\n  help                         Show this help message\n  validate                     Verify the skill is runnable (read-only)\n  grep [opts]                  Run a deterministic surface search\n\nOptions (grep):\n  --root <path>                default: .\n  --pattern <text>             repeatable (search terms)\n  --glob <pattern>             repeatable (rg -g)\n  --exclude <pattern>          repeatable (rg -g '!pat')\n  --mode <fixed|regex>         default: fixed\n  --case <sensitive|insensitive|smart>  default: smart\n  --context <n>                default: 0\n  --max-lines <n>              default: 500\n\nUsage:\n  grape grep --root . --pattern "foo" --glob "src/**/*.py"\n"""
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


def _resolve_root(root: str) -> Path:
    p = Path(root)
    if p.is_absolute():
        return p.resolve()
    return (REPO_ROOT / p).resolve()


def _is_match_line(line: str) -> bool:
    # Expected rg line format: path:line:content
    parts = line.split(":", 2)
    if len(parts) < 3:
        return False
    _, line_no, _ = parts
    return line_no.isdigit()


def cmd_grep(args: argparse.Namespace) -> int:
    root = args.root
    patterns: list[str] = args.pattern or []
    globs: list[str] = args.glob or []
    excludes: list[str] = args.exclude or []
    mode = args.mode
    case = args.case
    context = args.context
    max_lines = args.max_lines

    if not patterns:
        print("error: at least one --pattern is required", file=sys.stderr)
        return 2

    root_path = _resolve_root(root)

    argv: list[str] = [
        "rg",
        "-n",
        "--color",
        "never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--sort",
        "path",
    ]

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

    argv.append(str(root_path))

    param_block = {
        "root": root,
        "patterns": patterns,
        "globs": globs,
        "excludes": excludes,
        "mode": mode,
        "case": case,
        "context": context,
        "max_lines": max_lines,
        "tool": "rg",
        "argv": argv,
    }

    print(json.dumps(param_block, sort_keys=True))

    try:
        r = subprocess.run(argv, check=False, capture_output=True, text=True)
    except OSError as e:
        print(f"error: failed to run rg: {e}", file=sys.stderr)
        return 1

    if r.returncode not in (0, 1):
        if r.stderr:
            print(r.stderr.rstrip("\n"), file=sys.stderr)
        print(f"error: rg exited with status {r.returncode}", file=sys.stderr)
        return 1

    lines = [ln for ln in r.stdout.splitlines() if ln.strip()]
    match_lines = [ln for ln in lines if _is_match_line(ln)]
    files = sorted({ln.split(":", 1)[0] for ln in match_lines})

    truncated = False
    out_lines = lines
    if max_lines is not None and max_lines >= 0 and len(out_lines) > max_lines:
        out_lines = out_lines[:max_lines]
        truncated = True

    print(f"files: {len(files)}")
    print(f"matches: {len(match_lines)}")
    if truncated:
        print(f"truncated: true (showing first {len(out_lines)} lines)")

    for ln in out_lines:
        print(ln)

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="grape", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_grep = sub.add_parser("grep")
    p_grep.add_argument("--root", default=".")
    p_grep.add_argument("--pattern", action="append")
    p_grep.add_argument("--glob", action="append")
    p_grep.add_argument("--exclude", action="append")
    p_grep.add_argument("--mode", choices=["fixed", "regex"], default="fixed")
    p_grep.add_argument(
        "--case", choices=["sensitive", "insensitive", "smart"], default="smart"
    )
    p_grep.add_argument("--context", type=int, default=0)
    p_grep.add_argument("--max-lines", type=int, default=500)

    args = parser.parse_args()
    cmd = args.command or "help"

    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "grep":
        return cmd_grep(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
