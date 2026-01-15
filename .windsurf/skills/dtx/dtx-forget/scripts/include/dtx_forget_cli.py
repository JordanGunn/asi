#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path
from typing import Any

from dtx_common import repo_root_from_file, short_hash, utc_now_iso, yaml_dump, yaml_load


REPO_ROOT = repo_root_from_file(Path(__file__))
DTX_DIR = REPO_ROOT / ".dtx"
CONTRACT_PATH = DTX_DIR / "CONTRACT.yml"
FORGET_PATH = DTX_DIR / "FORGET.yml"


def _load_mapping(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    data = yaml_load(path)
    if data is None:
        return None
    if not isinstance(data, dict):
        raise ValueError(f"{path} is not a mapping")
    return data


def _load_forget_entries() -> list[dict[str, Any]]:
    if not FORGET_PATH.exists():
        return []
    data = yaml_load(FORGET_PATH)
    if data is None:
        return []
    if isinstance(data, list):
        return [e for e in data if isinstance(e, dict)]
    if isinstance(data, dict):
        maybe_entries = data.get("entries")
        if isinstance(maybe_entries, list):
            return [e for e in maybe_entries if isinstance(e, dict)]
        return []
    raise ValueError("forget file is not a list or mapping")


def _load_contract() -> dict[str, Any] | None:
    return _load_mapping(CONTRACT_PATH)


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """dtx-forget - Revoke a premise by appending to .dtx/FORGET.yml\n\nCommands:\n  help                 Show this help message\n  validate             Verify the skill is runnable (read-only)\n  forget <claim>       Record forget entry and update contract where safe\n  clean [--dry-run]    Remove .dtx/FORGET.yml\n\nUsage:\n  dtx-forget forget \"claim text\" --reason \"why\" [--scope global] [--replacement \"...\"]\n"""
    )
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    import importlib.util

    if importlib.util.find_spec("yaml") is None:
        print("error: missing dependency: pyyaml", file=sys.stderr)
        print("hint: run 'uv sync' in scripts/include/", file=sys.stderr)
        return 1

    print("ok: dtx-forget CLI is runnable")
    return 0


def cmd_forget(args: argparse.Namespace) -> int:
    DTX_DIR.mkdir(parents=True, exist_ok=True)

    now = utc_now_iso()
    scope = args.scope
    claim = args.claim
    reason = args.reason
    replacement = args.replacement or ""

    norm = "\n".join(
        [
            f"created_at={now}",
            f"scope={scope}",
            f"claim={claim}",
            f"reason={reason}",
            f"replacement={replacement}",
        ]
    )

    entry: dict[str, Any] = {
        "id": f"FGT-{short_hash(norm)}",
        "created_at": now,
        "schema_version": 1,
        "scope": scope,
        "claim": claim,
        "reason": reason,
    }
    if replacement:
        entry["replacement"] = replacement

    entries = _load_forget_entries()
    entries.append(entry)
    yaml_dump(entries, FORGET_PATH)

    contract = _load_contract()
    if contract is None:
        print(f"recorded: {entry['id']}")
        print("note: no contract found; did not update .dtx/CONTRACT.yml")
        return 0

    ws = contract.get("working_set")
    if not isinstance(ws, dict):
        ws = {}
        contract["working_set"] = ws

    conflict = False

    def remove_from(key: str) -> None:
        v = ws.get(key)
        if isinstance(v, list) and claim in v:
            ws[key] = [x for x in v if x != claim]

    for k in ["facts", "assumptions", "open_questions", "out_of_scope"]:
        remove_from(k)

    for k in ["decisions", "constraints"]:
        v = ws.get(k)
        if isinstance(v, list) and claim in v:
            conflict = True

    if not conflict:
        yaml_dump(contract, CONTRACT_PATH)
        print(f"recorded: {entry['id']}")
        print("updated: .dtx/CONTRACT.yml")
        return 0

    print(f"recorded: {entry['id']}")
    print("conflict: claim appears in decisions/constraints; contract not auto-edited", file=sys.stderr)
    return 2


def cmd_clean(args: argparse.Namespace) -> int:
    if args.dry_run:
        if FORGET_PATH.exists():
            print(f"would remove: {FORGET_PATH}")
        else:
            print("no forget file to clean")
        return 0

    if FORGET_PATH.exists():
        FORGET_PATH.unlink()
        print(f"removed: {FORGET_PATH}")
        return 0

    print("no forget file to clean")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="dtx-forget", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_forget = sub.add_parser("forget")
    p_forget.add_argument("claim")
    p_forget.add_argument("--scope", default="global")
    p_forget.add_argument("--reason", required=True)
    p_forget.add_argument("--replacement")

    p_clean = sub.add_parser("clean")
    p_clean.add_argument("--dry-run", action="store_true")

    args = parser.parse_args()
    cmd = args.command or "help"

    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "forget":
        return cmd_forget(args)
    if cmd == "clean":
        return cmd_clean(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
