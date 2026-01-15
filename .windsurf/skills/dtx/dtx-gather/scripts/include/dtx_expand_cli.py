#!/usr/bin/env python3

import argparse
import glob
import subprocess
import sys
from pathlib import Path
from typing import Any

import yaml

from dtx_common import repo_root_from_file, sha256_bytes, short_hash, utc_now_iso, yaml_dump


REPO_ROOT = repo_root_from_file(Path(__file__))
DTX_DIR = REPO_ROOT / ".dtx"
EXPANDS_DIR = DTX_DIR / "EXPANDS"


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """dtx-expand - Deterministic evidence gathering (glob + rg)\n\nCommands:\n  help                         Show this help message\n  validate                     Verify the skill is runnable (read-only)\n  expand [opts]                Create an EXP artifact bundle\n  clean [--id EXP-...]         Delete EXP artifacts (scoped)\n\nOptions (expand):\n  --root <path>                default: .\n  --glob <pattern>             repeatable\n  --pattern <rg pattern>       repeatable\n\nUsage:\n  dtx-expand expand --root . --glob \"src/**/*.py\" --pattern \"TODO\"\n"""
    )
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    import importlib.util
    import shutil

    errors: list[str] = []

    if importlib.util.find_spec("yaml") is None:
        errors.append("missing dependency: pyyaml")

    if shutil.which("rg") is None:
        errors.append("missing command: rg (ripgrep)")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        print("hint: install ripgrep and run 'uv sync' in scripts/include/", file=sys.stderr)
        return 1

    print("ok: dtx-expand CLI is runnable")
    return 0


def _normalized_inputs(root: str, globs_in: list[str], patterns_in: list[str]) -> str:
    doc = {
        "root": root,
        "globs": globs_in,
        "rg_patterns": patterns_in,
    }
    return yaml.safe_dump(doc, sort_keys=True)


def _select_files(root_path: Path, globs_in: list[str]) -> list[Path]:
    files: set[Path] = set()
    for g in globs_in:
        for m in glob.glob(str(root_path / g), recursive=True):
            p = Path(m)
            if p.is_file():
                files.add(p)
    return sorted(files, key=lambda p: str(p))


def _rg_matches(file_path: Path, patterns_in: list[str]) -> list[str]:
    out: list[str] = []
    for pat in patterns_in:
        try:
            r = subprocess.run(
                [
                    "rg",
                    "-n",
                    "--color",
                    "never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--",
                    pat,
                    str(file_path),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
        except OSError as e:
            raise RuntimeError(str(e))

        if r.stdout:
            out.extend([line for line in r.stdout.splitlines() if line.strip()])

    return out


def cmd_expand(args: argparse.Namespace) -> int:
    root = args.root
    globs_in = args.glob or []
    patterns_in = args.pattern or []

    if not globs_in and not patterns_in:
        print("error: at least one --glob or --pattern is required", file=sys.stderr)
        return 2

    now = utc_now_iso()

    norm = _normalized_inputs(root, globs_in, patterns_in)
    exp_id = f"EXP-{short_hash(norm)}"

    root_path = (REPO_ROOT / root).resolve() if not Path(root).is_absolute() else Path(root).resolve()

    out_dir = EXPANDS_DIR / exp_id
    out_dir.mkdir(parents=True, exist_ok=True)

    files = _select_files(root_path, globs_in) if globs_in else []
    rel_files = [str(f.resolve().relative_to(root_path)) for f in files]

    (out_dir / "files.txt").write_text("\n".join(rel_files) + ("\n" if rel_files else ""), encoding="utf-8")

    matches: list[str] = []
    if patterns_in and files:
        for f in files:
            matches.extend(_rg_matches(f, patterns_in))

    (out_dir / "matches.txt").write_text("\n".join(matches) + ("\n" if matches else ""), encoding="utf-8")

    output_hash = sha256_bytes((out_dir / "files.txt").read_bytes() + b"\n" + (out_dir / "matches.txt").read_bytes())

    meta: dict[str, Any] = {
        "schema_version": 1,
        "created_at": now,
        "expand": {"id": exp_id},
        "root": root,
        "globs": globs_in,
        "rg_patterns": patterns_in,
        "output_hash": output_hash,
    }

    yaml_dump(meta, out_dir / "meta.yml")

    print(f"expand.id: {exp_id}")
    print(f"files: {len(rel_files)}")
    print(f"matches: {len(matches)}")
    print(f"output_hash: {output_hash}")
    print(f"wrote: {out_dir}")

    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    import shutil

    if not EXPANDS_DIR.exists():
        print("no expands to clean")
        return 0

    if args.id:
        target = EXPANDS_DIR / args.id
        if target.exists():
            shutil.rmtree(target)
            print(f"removed: {target}")
            return 0
        print(f"error: missing EXP id: {args.id}", file=sys.stderr)
        return 1

    shutil.rmtree(EXPANDS_DIR)
    print(f"removed: {EXPANDS_DIR}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="dtx-expand", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_expand = sub.add_parser("expand")
    p_expand.add_argument("--root", default=".")
    p_expand.add_argument("--glob", action="append")
    p_expand.add_argument("--pattern", action="append")

    p_clean = sub.add_parser("clean")
    p_clean.add_argument("--id")

    args = parser.parse_args()
    cmd = args.command or "help"

    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "expand":
        return cmd_expand(args)
    if cmd == "clean":
        return cmd_clean(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
