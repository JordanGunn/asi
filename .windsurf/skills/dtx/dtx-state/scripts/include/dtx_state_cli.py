#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

import yaml

from dtx_common import read_contract, read_forget, repo_root_from_file


REPO_ROOT = repo_root_from_file(Path(__file__))
DTX_DIR = REPO_ROOT / ".dtx"
CONTRACT_PATH = DTX_DIR / "CONTRACT.yml"
FORGET_PATH = DTX_DIR / "FORGET.yml"


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """dtx-state - Present current admissible working set\n\nCommands:\n  help                 Show this help message\n  validate             Verify the skill is runnable (read-only)\n  show                 Show current state from .dtx/\n\nUsage:\n  dtx-state show\n\nReads:\n  .dtx/CONTRACT.yml\n  .dtx/FORGET.yml\n"""
    )
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    import importlib.util

    if importlib.util.find_spec("yaml") is None:
        print("error: missing dependency: pyyaml", file=sys.stderr)
        print("hint: run 'uv sync' in scripts/include/", file=sys.stderr)
        return 1

    print("ok: dtx-state CLI is runnable")
    return 0


def _print_section(title: str, items: list[str]) -> None:
    print(f"{title}:")
    if not items:
        print("  (none)")
        return
    for item in items:
        print(f"  - {item}")


def cmd_show(_: argparse.Namespace) -> int:
    contract = None
    forget = None

    try:
        contract = read_contract(CONTRACT_PATH)
        forget = read_forget(FORGET_PATH)
    except (OSError, ValueError, yaml.YAMLError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    if contract is None:
        print("no contract found: .dtx/CONTRACT.yml")
        template_path = Path(__file__).resolve().parents[2] / "assets" / "CONTRACT_TEMPLATE.yml"
        if template_path.exists():
            print("\nblank template:\n")
            print(template_path.read_text(encoding="utf-8").rstrip())
        return 0

    intent = contract.get("intent", "")
    print(f"intent: {intent}")

    ws = contract.get("working_set") or {}
    if not isinstance(ws, dict):
        ws = {}

    _print_section("decisions", ws.get("decisions") or [])
    _print_section("constraints", ws.get("constraints") or [])
    _print_section("facts", ws.get("facts") or [])
    _print_section("assumptions", ws.get("assumptions") or [])
    _print_section("open_questions", ws.get("open_questions") or [])

    entries = []
    if isinstance(forget, list):
        entries = forget
    elif isinstance(forget, dict):
        maybe_entries = forget.get("entries")
        if isinstance(maybe_entries, list):
            entries = maybe_entries

    print("revoked_premises:")
    if not entries:
        print("  (none)")
        return 0

    print(f"  count: {len(entries)}")
    for e in entries[-5:]:
        claim = ""
        if isinstance(e, dict):
            claim = str(e.get("claim", ""))
        if claim:
            print(f"  - {claim}")

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="dtx-state", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")
    sub.add_parser("show")

    args = parser.parse_args()

    cmd = args.command or "help"
    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "show":
        return cmd_show(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
