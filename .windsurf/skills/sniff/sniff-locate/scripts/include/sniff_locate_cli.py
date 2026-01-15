from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


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


def cmd_help() -> int:
    print("sniff-locate commands:")
    print("  help")
    print("  validate")
    print("  list [--all] [--smell NAME] [--group GROUP] [--path GLOB] [--json]")
    print("  validate-findings [--all]")
    print("  reanchor [--all]")
    print("  clean")
    return 0


def cmd_validate() -> int:
    repo_root = _repo_root()
    shared = repo_root / "skills" / "sniff" / ".shared" / "scripts" / "include"
    if not (shared / "sniff_locate.py").exists():
        print(f"error: missing shared implementation at {shared}", file=sys.stderr)
        return 1
    if not (repo_root / ".git").exists():
        print("error: not a git repository (missing .git)", file=sys.stderr)
        return 1

    print("ok: sniff-locate cli is runnable")
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    repo_root = _repo_root()
    _add_shared_include(repo_root)
    from sniff_locate import format_human, format_json, list_findings

    rows = list_findings(
        repo_root,
        smell=args.smell,
        group=args.group,
        path_glob=args.path,
        include_all=args.all,
    )
    if args.json:
        sys.stdout.write(format_json(rows))
    else:
        sys.stdout.write(format_human(rows))
    return 0


def cmd_validate_findings(args: argparse.Namespace, *, reanchor: bool) -> int:
    repo_root = _repo_root()
    _add_shared_include(repo_root)
    from sniff_locate import validate_findings

    counts = validate_findings(repo_root, reanchor=reanchor, include_all=args.all)
    print(
        "ok: "
        + ", ".join(
            [
                f"active={counts.get('active', 0)}",
                f"stale={counts.get('stale', 0)}",
                f"missing={counts.get('missing', 0)}",
                f"updated={counts.get('updated', 0)}",
            ]
        )
    )
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
    print("ok: cleaned derived .sniff artifacts (index/state)")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    sub = parser.add_subparsers(dest="cmd")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_list = sub.add_parser("list")
    p_list.add_argument("--all", action="store_true")
    p_list.add_argument("--smell")
    p_list.add_argument("--group")
    p_list.add_argument("--path")
    p_list.add_argument("--json", action="store_true")

    p_v = sub.add_parser("validate-findings")
    p_v.add_argument("--all", action="store_true")

    p_r = sub.add_parser("reanchor")
    p_r.add_argument("--all", action="store_true")

    sub.add_parser("clean")

    ns = parser.parse_args(argv[1:] if len(argv) > 1 else [])
    cmd = ns.cmd or "help"

    if cmd == "help":
        return cmd_help()
    if cmd == "validate":
        return cmd_validate()
    if cmd == "list":
        return cmd_list(ns)
    if cmd == "validate-findings":
        return cmd_validate_findings(ns, reanchor=False)
    if cmd == "reanchor":
        return cmd_validate_findings(ns, reanchor=True)
    if cmd == "clean":
        return cmd_clean()

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
