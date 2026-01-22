#!/usr/bin/env python3

import argparse
import importlib.util
import sys

from prompt_parse import ACTIVE_PATH, artifact_exists, compile_to_markdown, load_artifact, validate_artifact, write_compiled


def cmd_help() -> int:
    print(
        """prompt-compile - Compile .prompt/active.yaml into .prompt/PROMPT.md

Usage:
  prompt-compile [--dry-run]
  prompt-compile help
  prompt-compile validate

Deterministic behavior:
- Verifies active artifact exists
- Validates artifact (schema)
- Writes .prompt/PROMPT.md (unless --dry-run)
- Preserves active artifact
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

    print("ok: prompt-compile CLI is runnable")
    return 0


def cmd_compile(dry_run: bool) -> int:
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        print(f"path: {ACTIVE_PATH} (does not exist)", file=sys.stderr)
        print("use prompt-forge to create one first", file=sys.stderr)
        return 1

    artifact = load_artifact() or {}
    errors = validate_artifact(artifact)

    if errors:
        print("error: artifact has validation errors", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    if artifact.get("status") != "ready":
        print(f"error: prompt status is '{artifact.get('status')}', not 'ready'", file=sys.stderr)
        print("use prompt-forge to finish refinement first", file=sys.stderr)
        return 1

    content = compile_to_markdown(artifact)

    if dry_run:
        print("--- PROMPT.md (dry-run) ---")
        print(content)
        return 0

    output_path = write_compiled(content)
    print(f"compiled: {output_path}")
    print(f"artifact: {ACTIVE_PATH} (preserved)")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="prompt-compile", add_help=False)
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

    return cmd_compile(dry_run=args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
