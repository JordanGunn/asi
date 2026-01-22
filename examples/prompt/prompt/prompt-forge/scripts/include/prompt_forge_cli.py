#!/usr/bin/env python3

import argparse
import importlib.util
import sys

from prompt_parse import ACTIVE_PATH, artifact_exists, create_empty_artifact, load_artifact, save_artifact, validate_artifact


def cmd_help() -> int:
    print(
        """prompt-forge - Shape and stabilize intent into .prompt/active.yaml

Usage:
  prompt-forge [--mark-ready]
  prompt-forge help
  prompt-forge validate

Deterministic behavior:
- Ensures .prompt/active.yaml exists (creates it if missing)
- Prints current artifact status
- Optionally marks artifact ready (requires no open questions, and requires a prompt)
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

    print("ok: prompt-forge CLI is runnable")
    return 0


def print_status() -> int:
    if not artifact_exists():
        print("status: no active prompt")
        print(f"path: {ACTIVE_PATH} (does not exist)")
        return 0

    artifact = load_artifact() or {}
    errors = validate_artifact(artifact)

    print(f"status: {artifact.get('status', 'unknown')}")
    print(f"path: {ACTIVE_PATH}")
    print(f"created: {artifact.get('created_at', 'unknown')}")
    print(f"updated: {artifact.get('updated_at', 'unknown')}")

    intent = artifact.get("intent", {})
    objective = intent.get("objective", "")
    print(f"objective: {objective[:60]}..." if len(objective) > 60 else f"objective: {objective or '(empty)'}")

    open_q = intent.get("open_questions", [])
    print(f"open_questions: {len(open_q)}")

    if errors:
        print(f"errors: {len(errors)}")
        for e in errors:
            print(f"  - {e}")

    return 0


def ensure_artifact_exists() -> None:
    if artifact_exists():
        return
    artifact = create_empty_artifact()
    save_artifact(artifact)


def mark_ready() -> int:
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        return 1

    artifact = load_artifact() or {}

    if artifact.get("status") == "ready":
        print("already ready")
        return 0

    intent = artifact.get("intent", {})
    open_q = intent.get("open_questions", [])

    if open_q:
        print(f"error: {len(open_q)} open questions remain", file=sys.stderr)
        for q in open_q:
            print(f"  - {q}", file=sys.stderr)
        return 1

    if not artifact.get("prompt"):
        print("error: no prompt text set", file=sys.stderr)
        return 1

    artifact["status"] = "ready"
    save_artifact(artifact)
    print("status: ready")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="prompt-forge", add_help=False)
    parser.add_argument("command", nargs="?", help="help or validate")
    parser.add_argument("--mark-ready", action="store_true")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "help":
        return cmd_help()

    if args.command == "validate":
        return cmd_validate()

    ensure_artifact_exists()

    if args.mark_ready:
        return mark_ready()

    return print_status()


if __name__ == "__main__":
    sys.exit(main())
