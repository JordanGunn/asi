#!/usr/bin/env python3
"""Prompt CLI - Artifact management for prompt skillset."""

import argparse
import sys

from prompt_parse import (
    ACTIVE_PATH,
    COMPILED_PATH,
    PROMPT_DIR,
    artifact_exists,
    compile_to_markdown,
    compiled_exists,
    create_empty_artifact,
    delete_artifact,
    list_receipts,
    load_artifact,
    save_artifact,
    validate_artifact,
    write_compiled,
    write_receipt,
)


def cmd_status(args: argparse.Namespace) -> int:
    """Show current artifact state."""
    if not artifact_exists():
        print("status: no active prompt")
        print(f"path: {ACTIVE_PATH} (does not exist)")
        return 0
    
    artifact = load_artifact()
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


def cmd_init(args: argparse.Namespace) -> int:
    """Initialize a new empty artifact."""
    if artifact_exists() and not args.force:
        print("error: active prompt already exists", file=sys.stderr)
        print("use --force to overwrite", file=sys.stderr)
        return 1
    
    artifact = create_empty_artifact()
    save_artifact(artifact)
    print(f"created: {ACTIVE_PATH}")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    """Display current artifact content."""
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        return 1
    
    content = ACTIVE_PATH.read_text(encoding="utf-8")
    print(content)
    return 0


def cmd_ready(args: argparse.Namespace) -> int:
    """Mark artifact as ready for execution."""
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        return 1
    
    artifact = load_artifact()
    
    if artifact.get("status") == "ready":
        print("already ready")
        return 0
    
    intent = artifact.get("intent", {})
    open_q = intent.get("open_questions", [])
    
    if open_q and not args.force:
        print(f"error: {len(open_q)} open questions remain", file=sys.stderr)
        for q in open_q:
            print(f"  - {q}", file=sys.stderr)
        print("use --force to mark ready anyway", file=sys.stderr)
        return 1
    
    if not artifact.get("prompt"):
        print("error: no prompt text set", file=sys.stderr)
        return 1
    
    artifact["status"] = "ready"
    save_artifact(artifact)
    print("status: ready")
    return 0


def cmd_exec(args: argparse.Namespace) -> int:
    """Execute the prompt (write receipt, delete artifact)."""
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        print("use prompt-forge to create one first", file=sys.stderr)
        return 1
    
    artifact = load_artifact()
    
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
    
    if args.dry_run:
        print("dry-run: would execute and delete artifact")
        print(f"prompt: {artifact.get('prompt', '')[:100]}...")
        return 0
    
    receipt_path = write_receipt(artifact)
    print(f"receipt: {receipt_path}")
    
    delete_artifact()
    print(f"deleted: {ACTIVE_PATH}")
    
    print("---")
    print("PROMPT TO EXECUTE:")
    print(artifact.get("prompt", ""))
    
    return 0


def cmd_receipts(args: argparse.Namespace) -> int:
    """List execution receipts."""
    receipts = list_receipts()
    
    if not receipts:
        print("no receipts found")
        return 0
    
    for r in receipts:
        print(r.name)
    
    return 0


def cmd_compile(args: argparse.Namespace) -> int:
    """Compile artifact to PROMPT.md."""
    if not artifact_exists():
        print("error: no active prompt", file=sys.stderr)
        print("use prompt-forge to create one first", file=sys.stderr)
        return 1
    
    artifact = load_artifact()
    errors = validate_artifact(artifact)
    
    if errors and not args.force:
        print("error: artifact has validation errors", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        print("use --force to compile anyway", file=sys.stderr)
        return 1
    
    content = compile_to_markdown(artifact)
    
    if args.dry_run:
        print("--- PROMPT.md (dry-run) ---")
        print(content)
        return 0
    
    output_path = write_compiled(content)
    print(f"compiled: {output_path}")
    print(f"artifact: {ACTIVE_PATH} (preserved)")
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    """Remove all prompt artifacts."""
    if not PROMPT_DIR.exists():
        print("nothing to clean")
        return 0
    
    if args.dry_run:
        print(f"would remove: {PROMPT_DIR}")
        return 0
    
    import shutil
    shutil.rmtree(PROMPT_DIR)
    print(f"removed: {PROMPT_DIR}")
    return 0


def cmd_help(args: argparse.Namespace) -> int:
    """Show help."""
    print("""prompt - Prompt artifact management CLI

Commands:
  help      Show this help message
  validate  Verify the skill is runnable
  status    Show current artifact state
  init      Create a new empty artifact
  show      Display artifact content
  ready     Mark artifact as ready
  compile   Compile artifact to PROMPT.md
  exec      Execute prompt (write receipt, delete artifact)
  receipts  List execution receipts
  clean     Remove all artifacts

Usage:
  prompt status
  prompt init [--force]
  prompt show
  prompt ready [--force]
  prompt compile [--force] [--dry-run]
  prompt exec [--dry-run]
  prompt receipts
  prompt clean [--dry-run]

Artifacts are stored in .prompt/active.yaml
Compiled output: .prompt/PROMPT.md
Receipts are stored in .prompt/receipts/
""")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Validate CLI is runnable."""
    import importlib.util
    errors = []
    
    if importlib.util.find_spec("yaml") is None:
        errors.append("missing dependency: pyyaml")
    
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    
    print("ok: prompt CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="prompt", description="Prompt artifact management")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("help", help="Show help")
    subparsers.add_parser("validate", help="Verify CLI is runnable")
    subparsers.add_parser("status", help="Show artifact state")
    
    p_init = subparsers.add_parser("init", help="Create empty artifact")
    p_init.add_argument("--force", action="store_true", help="Overwrite existing")
    
    subparsers.add_parser("show", help="Display artifact content")
    
    p_ready = subparsers.add_parser("ready", help="Mark as ready")
    p_ready.add_argument("--force", action="store_true", help="Ignore open questions")
    
    p_exec = subparsers.add_parser("exec", help="Execute prompt")
    p_exec.add_argument("--dry-run", action="store_true", help="Show what would happen")
    
    subparsers.add_parser("receipts", help="List receipts")
    
    p_compile = subparsers.add_parser("compile", help="Compile to PROMPT.md")
    p_compile.add_argument("--force", action="store_true", help="Compile despite errors")
    p_compile.add_argument("--dry-run", action="store_true", help="Show output without writing")
    
    p_clean = subparsers.add_parser("clean", help="Remove artifacts")
    p_clean.add_argument("--dry-run", action="store_true", help="Show what would be removed")
    
    args = parser.parse_args()
    
    commands = {
        "help": cmd_help,
        "validate": cmd_validate,
        "status": cmd_status,
        "init": cmd_init,
        "show": cmd_show,
        "ready": cmd_ready,
        "compile": cmd_compile,
        "exec": cmd_exec,
        "receipts": cmd_receipts,
        "clean": cmd_clean,
    }
    
    cmd = args.command or "help"
    if cmd not in commands:
        print(f"error: unknown command '{cmd}'", file=sys.stderr)
        return 1
    
    return commands[cmd](args)


if __name__ == "__main__":
    sys.exit(main())
