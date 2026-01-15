#!/usr/bin/env python3

import argparse
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml

from dtx_common import repo_root_from_file, sha256_bytes, yaml_load


REPO_ROOT = repo_root_from_file(Path(__file__))
DTX_DIR = REPO_ROOT / ".dtx"
CONTRACT_PATH = DTX_DIR / "CONTRACT.yml"
FORGET_PATH = DTX_DIR / "FORGET.yml"
EXPANDS_DIR = DTX_DIR / "EXPANDS"


def cmd_help(_: argparse.Namespace) -> int:
    print(
        """dtx-validate - Validate .dtx artifacts (read-only)\n\nCommands:\n  help                             Show this help message\n  validate                         Verify the skill is runnable (read-only)\n  check [--max-age-days N]          Validate contract/forget/expands\n\nUsage:\n  dtx-validate check\n  dtx-validate check --max-age-days 7\n\nChecks:\n  .dtx/CONTRACT.yml\n  .dtx/FORGET.yml\n  .dtx/EXPANDS/*\n"""
    )
    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    import importlib.util

    if importlib.util.find_spec("yaml") is None:
        print("error: missing dependency: pyyaml", file=sys.stderr)
        print("hint: run 'uv sync' in scripts/include/", file=sys.stderr)
        return 1

    print("ok: dtx-validate CLI is runnable")
    return 0


def _parse_iso(s: str) -> datetime | None:
    s = (s or "").strip()
    if not s:
        return None
    try:
        if s.endswith("Z"):
            s = s[:-1] + "+00:00"
        return datetime.fromisoformat(s)
    except ValueError:
        return None


def _is_list_of_strings(v: Any) -> bool:
    return isinstance(v, list) and all(isinstance(x, str) for x in v)


def _validate_contract() -> list[str]:
    errors: list[str] = []
    if not CONTRACT_PATH.exists():
        return errors

    data = yaml_load(CONTRACT_PATH)
    if data is None:
        errors.append("contract is empty")
        return errors
    if not isinstance(data, dict):
        errors.append("contract is not a mapping")
        return errors

    if data.get("schema_version") != 1:
        errors.append("contract.schema_version must be 1")

    ws = data.get("working_set")
    if not isinstance(ws, dict):
        errors.append("contract.working_set must be a mapping")
        return errors

    for k in ["decisions", "constraints", "facts", "assumptions", "open_questions", "out_of_scope"]:
        v = ws.get(k)
        if v is None:
            continue
        if not _is_list_of_strings(v):
            errors.append(f"contract.working_set.{k} must be a list of strings")

    return errors


def _forget_entries(data: Any) -> list[dict[str, Any]]:
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


def _validate_forget() -> list[str]:
    errors: list[str] = []
    if not FORGET_PATH.exists():
        return errors

    data = yaml_load(FORGET_PATH)
    try:
        entries = _forget_entries(data)
    except ValueError as e:
        return [str(e)]

    for i, e in enumerate(entries):
        if e.get("schema_version") != 1:
            errors.append(f"forget[{i}].schema_version must be 1")
        if not str(e.get("id", "")).startswith("FGT-"):
            errors.append(f"forget[{i}].id must start with FGT-")
        for req in ["created_at", "scope", "claim", "reason"]:
            if not str(e.get(req, "")).strip():
                errors.append(f"forget[{i}].{req} is required")

    return errors


def _validate_expands() -> list[str]:
    errors: list[str] = []
    if not EXPANDS_DIR.exists():
        return errors

    for p in sorted(EXPANDS_DIR.iterdir(), key=lambda x: str(x)):
        if not p.is_dir():
            continue

        files_txt = p / "files.txt"
        matches_txt = p / "matches.txt"
        meta_yml = p / "meta.yml"

        for required in [files_txt, matches_txt, meta_yml]:
            if not required.exists():
                errors.append(f"expand {p.name}: missing {required.name}")

        if not files_txt.exists() or not matches_txt.exists() or not meta_yml.exists():
            continue

        meta = yaml_load(meta_yml)
        if not isinstance(meta, dict):
            errors.append(f"expand {p.name}: meta.yml is not a mapping")
            continue

        if meta.get("schema_version") != 1:
            errors.append(f"expand {p.name}: meta.schema_version must be 1")

        computed = sha256_bytes(files_txt.read_bytes() + b"\n" + matches_txt.read_bytes())
        expected = str(meta.get("output_hash", ""))
        if expected and expected != computed:
            errors.append(f"expand {p.name}: output_hash mismatch")

    return errors


def _check_staleness(max_age_days: float | None) -> tuple[bool, str | None]:
    if max_age_days is None:
        return (False, None)
    if not CONTRACT_PATH.exists():
        return (False, None)

    data = yaml_load(CONTRACT_PATH)
    if not isinstance(data, dict):
        return (False, None)

    created_at = _parse_iso(str(data.get("created_at", "")))
    if created_at is None:
        return (False, "stale_check: contract.created_at is missing or invalid")

    now = datetime.now(timezone.utc)
    if created_at.tzinfo is None:
        created_at = created_at.replace(tzinfo=timezone.utc)

    age_days = (now - created_at).total_seconds() / 86400.0
    if age_days > max_age_days:
        return (True, f"stale_check: contract age {age_days:.2f}d exceeds {max_age_days:.2f}d")
    return (False, None)


def cmd_check(args: argparse.Namespace) -> int:
    errors: list[str] = []

    try:
        errors.extend(_validate_contract())
        errors.extend(_validate_forget())
        errors.extend(_validate_expands())
    except (OSError, yaml.YAMLError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    stale, stale_msg = _check_staleness(args.max_age_days)

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    if stale_msg:
        if stale:
            print(f"error: {stale_msg}", file=sys.stderr)
            return 2
        print(f"warning: {stale_msg}", file=sys.stderr)

    print("ok: dtx artifacts validate")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="dtx-validate", add_help=False)
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("help")
    sub.add_parser("validate")

    p_check = sub.add_parser("check")
    p_check.add_argument("--max-age-days", type=float)

    args = parser.parse_args()
    cmd = args.command or "help"

    if cmd == "help":
        return cmd_help(args)
    if cmd == "validate":
        return cmd_validate(args)
    if cmd == "check":
        return cmd_check(args)

    print(f"error: unknown command '{cmd}'", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
