#!/usr/bin/env python3
"""Plan CLI - Artifact management for plan skillset."""

import argparse
import sys

from plan_parse import (
    PLAN_DIR,
    clean_all_plans,
    clean_plan,
    get_plan_status,
    init_plan,
    list_plans,
    next_plan_number,
    plan_exists,
    surface_scan,
)


def cmd_list(args: argparse.Namespace) -> int:
    """List all plans."""
    plans = list_plans()
    if not plans:
        print("no plans found")
        return 0
    
    for n in plans:
        status = get_plan_status(n)
        title = status.get("title", "")
        st = status.get("status", "pending")
        print(f"{n:3d}  [{st:12s}]  {title}")
    
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    """Show plan status."""
    n = args.plan
    if n is None:
        plans = list_plans()
        if not plans:
            print("no plans found")
            return 1
        n = max(plans)
    
    if not plan_exists(n):
        print(f"error: plan {n} does not exist", file=sys.stderr)
        return 1
    
    status = get_plan_status(n)
    
    print(f"plan: {n}")
    print(f"status: {status.get('status', 'pending')}")
    print(f"title: {status.get('title', '')}")
    print()
    
    subplans = status.get("subplans", [])
    if subplans:
        print("subplans:")
        for sp in subplans:
            letter = sp["letter"]
            tasks = sp["tasks"]
            complete = sum(1 for t in tasks if t["status"] == "complete")
            total = len(tasks)
            print(f"  {letter}/ — {complete}/{total} tasks complete")
            for t in tasks:
                roman = t["roman"]
                st = t["status"]
                marker = "✓" if st == "complete" else "○" if st == "pending" else "→"
                print(f"    {marker} {roman} [{st}]")
    
    return 0


def cmd_next(args: argparse.Namespace) -> int:
    """Get next plan number."""
    n = next_plan_number()
    print(n)
    return 0


def cmd_init(args: argparse.Namespace) -> int:
    """Initialize a new plan."""
    n = args.plan
    if n is None:
        n = next_plan_number()
    
    if plan_exists(n) and not args.force:
        print(f"error: plan {n} already exists", file=sys.stderr)
        print("use --force to overwrite", file=sys.stderr)
        return 1
    
    if plan_exists(n) and args.force:
        clean_plan(n)
    
    title = args.title or ""
    path = init_plan(n, title)
    print(f"created: {path}")
    print(f"  plan.md")
    print(f"  a/index.md")
    print(f"  a/i.md")
    return 0


def cmd_surface(args: argparse.Namespace) -> int:
    """Scan for relevant files."""
    patterns = args.patterns if args.patterns else None
    files = surface_scan(patterns)
    
    if not files:
        print("no files found")
        return 0
    
    print(f"found {len(files)} files:")
    for f in files[:50]:  # Limit output
        print(f"  {f}")
    
    if len(files) > 50:
        print(f"  ... and {len(files) - 50} more")
    
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    """Remove plan artifacts."""
    if args.all:
        if args.dry_run:
            plans = list_plans()
            print(f"would remove {len(plans)} plans")
            return 0
        count = clean_all_plans()
        print(f"removed {count} plans")
        return 0
    
    n = args.plan
    if n is None:
        print("error: specify plan number or --all", file=sys.stderr)
        return 1
    
    if not plan_exists(n):
        print(f"error: plan {n} does not exist", file=sys.stderr)
        return 1
    
    if args.dry_run:
        print(f"would remove: {PLAN_DIR / str(n)}")
        return 0
    
    clean_plan(n)
    print(f"removed: {PLAN_DIR / str(n)}")
    return 0


def cmd_help(args: argparse.Namespace) -> int:
    """Show help."""
    print("""plan - Plan artifact management CLI

Commands:
  help           Show this help message
  validate       Verify the skill is runnable
  list           List all plans
  status [N]     Show plan N status (default: latest)
  next           Get next plan number
  init [N]       Initialize plan N (default: next)
  surface        Scan for relevant files
  clean <N>      Remove plan N
  clean --all    Remove all plans

Usage:
  plan list
  plan status
  plan status 5
  plan next
  plan init
  plan init 10 --title "Migration"
  plan surface
  plan surface --patterns "*.py" "*.md"
  plan clean 5
  plan clean --all [--dry-run]

Plans are stored in .plan/<N>/
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
    
    print("ok: plan CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="plan", description="Plan artifact management")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("help", help="Show help")
    subparsers.add_parser("validate", help="Verify CLI is runnable")
    subparsers.add_parser("list", help="List all plans")
    
    p_status = subparsers.add_parser("status", help="Show plan status")
    p_status.add_argument("plan", type=int, nargs="?", help="Plan number")
    
    subparsers.add_parser("next", help="Get next plan number")
    
    p_init = subparsers.add_parser("init", help="Initialize plan")
    p_init.add_argument("plan", type=int, nargs="?", help="Plan number")
    p_init.add_argument("--title", help="Plan title")
    p_init.add_argument("--force", action="store_true", help="Overwrite existing")
    
    p_surface = subparsers.add_parser("surface", help="Scan for files")
    p_surface.add_argument("--patterns", nargs="*", help="File patterns")
    
    p_clean = subparsers.add_parser("clean", help="Remove plan")
    p_clean.add_argument("plan", type=int, nargs="?", help="Plan number")
    p_clean.add_argument("--all", action="store_true", help="Remove all plans")
    p_clean.add_argument("--dry-run", action="store_true", help="Show what would be removed")
    
    args = parser.parse_args()
    
    commands = {
        "help": cmd_help,
        "validate": cmd_validate,
        "list": cmd_list,
        "status": cmd_status,
        "next": cmd_next,
        "init": cmd_init,
        "surface": cmd_surface,
        "clean": cmd_clean,
    }
    
    cmd = args.command or "help"
    if cmd not in commands:
        print(f"error: unknown command '{cmd}'", file=sys.stderr)
        return 1
    
    return commands[cmd](args)


if __name__ == "__main__":
    sys.exit(main())
