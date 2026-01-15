from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path
from typing import Any


def _repo_root() -> Path:
    proc = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode == 0:
        p = proc.stdout.decode("utf-8", errors="replace").strip()
        if p:
            return Path(p)
    return Path.cwd()


def _add_shared_include(repo_root: Path) -> None:
    shared = repo_root / "skills" / "sniff" / ".shared" / "scripts" / "include"
    sys.path.insert(0, str(shared))


def _parse_thresholds(items: list[str] | None) -> dict[str, Any]:
    out: dict[str, Any] = {}
    if not items:
        return out
    for it in items:
        if "=" not in it:
            continue
        k, v = it.split("=", 1)
        k = k.strip()
        v = v.strip()
        if not k:
            continue
        try:
            out[k] = int(v)
        except Exception:
            out[k] = v
    return out


def cmd_help() -> int:
    print("sniff-bloaters commands:")
    print("  help")
    print("  validate")
    print("  scan [--threshold k=v]...")
    print("  clean")
    return 0


def cmd_validate() -> int:
    repo_root = _repo_root()
    shared = repo_root / "skills" / "sniff" / ".shared" / "scripts" / "include"
    if not (shared / "sniff_scan.py").exists():
        print(f"error: missing shared implementation at {shared}", file=sys.stderr)
        return 1
    if not (repo_root / ".git").exists():
        print("error: not a git repository (missing .git)", file=sys.stderr)
        return 1

    print("ok: sniff-bloaters cli is runnable")
    return 0


def cmd_scan(args: argparse.Namespace) -> int:
    repo_root = _repo_root()
    _add_shared_include(repo_root)
    from sniff_scan import scan_group

    thresholds = _parse_thresholds(args.threshold)
    n = scan_group(repo_root, "bloaters", thresholds=thresholds)
    print(f"ok: appended {n} new finding(s)")
    return 0


def cmd_clean() -> int:
    repo_root = _repo_root()
    sniff_dir = repo_root / ".sniff"
    for p in [sniff_dir / "index.json", sniff_dir / "state.json"]:
        try:
            if p.exists():
                p.unlink()
        except Exception:
            pass
    cache = sniff_dir / "cache"
    if cache.exists() and cache.is_dir():
        for child in sorted(cache.rglob("*"), reverse=True):
            try:
                if child.is_file():
                    child.unlink()
                elif child.is_dir():
                    child.rmdir()
            except Exception:
                pass
        try:
            cache.rmdir()
        except Exception:
            pass
    print("ok: cleaned derived .sniff artifacts (index/state/cache)")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    sub = parser.add_subparsers(dest="cmd")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_scan = sub.add_parser("scan")
    p_scan.add_argument("--threshold", action="append", default=[], help="override threshold, e.g. long_method_lines=100")

    sub.add_parser("clean")

    ns = parser.parse_args(argv[1:] if len(argv) > 1 else [])
    cmd = ns.cmd or "help"

    if cmd == "help":
        return cmd_help()
    if cmd == "validate":
        return cmd_validate()
    if cmd == "scan":
        return cmd_scan(ns)
    if cmd == "clean":
        return cmd_clean()

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
