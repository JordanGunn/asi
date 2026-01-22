#!/usr/bin/env python3

import argparse
import importlib.util
import sys

from prompt_parse import ACTIVE_PATH, artifact_exists, delete_artifact, load_artifact, validate_artifact, write_receipt


def cmd_help() -> int:
    print(
        """prompt-exec - Execute the forged prompt exactly as written

Usage:
  prompt-exec [--dry-run]
  prompt-exec help
  prompt-exec validate

Deterministic behavior:
- Requires .prompt/active.yaml exists
- Requires artifact status is ready
- Writes receipt to .prompt/receipts/
- Deletes .prompt/active.yaml after successful execution
- Prints the prompt text to execute
"""
    )
    return 0


def cmd_validate() -> int:
    errors: list[str] = []

    if importlib.util.find_spec("yaml") is None:
        errors.append("missing dependency: pyyaml")
    if importlib.util.find_spec("jsonschema") is None:
        errors.append("missing dependency: jsonschema")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    print("ok: prompt-exec CLI is runnable")
    return 0


def cmd_exec(dry_run: bool) -> int:
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        print(f"path: {ACTIVE_PATH} (does not exist)", file=sys.stderr)
        print("use prompt-forge to create one first", file=sys.stderr)
        return 1

    artifact = load_artifact() or {}

    if artifact.get("status") != "ready":
        print(f"error: prompt status is '{artifact.get('status')}', not 'ready'", file=sys.stderr)
        print("use prompt-forge to complete refinement first", file=sys.stderr)
        return 1

    errors = validate_artifact(artifact)
    if errors:
        print("error: artifact validation failed", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    if dry_run:
        print("dry-run: would execute and delete artifact")
        print(f"prompt: {artifact.get('prompt', '')[:100]}...")
        return 0

    receipt_path = write_receipt(artifact, execution_status="success")
    print(f"receipt: {receipt_path}")

    delete_artifact()
    print(f"deleted: {ACTIVE_PATH}")

    print("---")
    print("PROMPT TO EXECUTE:")
    print(artifact.get("prompt", ""))

    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="prompt-exec", add_help=False)
    parser.add_argument("command", nargs="?", help="help or validate")
    parser.add_argument("--dry-run", action="store_true")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "help":
        return cmd_help()

    if args.command == "validate":
        return cmd_validate()

    if args.command not in (None, ""):
        print(f"error: unknown command '{args.command}'", file=sys.stderr)
        return 1

    return cmd_exec(dry_run=args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
