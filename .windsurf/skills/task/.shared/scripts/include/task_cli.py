#!/usr/bin/env python3
"""Task CLI - Single entry point for task management."""

import argparse
import importlib.util
import sys
from typing import Any

from task_hash import compute_intent_hash, verify_intent_hash
from task_parse import (
    get_task_path,
    get_tasks_dir,
    list_task_files,
    parse_task_file,
    read_active_task,
    serialize_task,
    write_active_task,
)
from task_time import is_stale, now_utc, to_rfc3339


def cmd_create(args: argparse.Namespace) -> int:
    """Create a new task."""
    tasks_dir = get_tasks_dir()
    tasks_dir.mkdir(exist_ok=True)
    
    task_id = args.id
    task_path = get_task_path(task_id)
    
    if task_path.exists():
        print(f"error: task '{task_id}' already exists", file=sys.stderr)
        return 1
    
    now = to_rfc3339(now_utc())
    
    body = f"""## Goal

{args.goal or 'TODO: Define the goal'}

## Acceptance

- [ ] TODO: Define acceptance criteria

## Constraints

- None specified

## Dependencies

- None

## Evidence

<!-- Evidence section is excluded from intent hash -->
"""
    
    frontmatter: dict[str, Any] = {
        "id": task_id,
        "title": args.title or task_id.replace("-", " ").title(),
        "kind": args.kind,
        "risk": args.risk,
        "state": "draft",
        "created_at": now,
        "updated_at": now,
        "intent_hash_algo": "sha256-v1",
        "intent_hash_scope": "canonical-intent",
        "staleness_days_threshold": 21,
    }
    
    content = serialize_task(frontmatter, body)
    intent_hash = compute_intent_hash(content)
    frontmatter["intent_hash"] = intent_hash
    
    final_content = serialize_task(frontmatter, body)
    task_path.write_text(final_content, encoding="utf-8")
    
    print(f"created: {task_path}")
    
    if args.select:
        write_active_task(task_id)
        print(f"selected: {task_id}")
    
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    """List tasks with derived flags."""
    task_files = list_task_files()
    
    if not task_files:
        print("no tasks found in .tasks/")
        return 0
    
    active_id = read_active_task()
    tasks = []
    
    for path in task_files:
        fm, body = parse_task_file(path)
        if not fm.get("id"):
            continue
        
        if args.state and fm.get("state") != args.state:
            continue
        
        stale, stale_reason = is_stale(
            fm.get("last_reviewed_at"),
            fm.get("updated_at"),
            fm.get("created_at", ""),
            fm.get("staleness_days_threshold", 21),
        )
        
        if args.stale and not stale:
            continue
        
        content = path.read_text(encoding="utf-8")
        hash_ok, _ = verify_intent_hash(content, fm.get("intent_hash"))
        
        tasks.append({
            "id": fm["id"],
            "title": fm.get("title", ""),
            "state": fm.get("state", "?"),
            "kind": fm.get("kind", "?"),
            "risk": fm.get("risk", "?"),
            "updated_at": fm.get("updated_at", ""),
            "is_active": fm["id"] == active_id,
            "is_stale": stale,
            "stale_reason": stale_reason,
            "hash_mismatch": not hash_ok,
        })
    
    tasks.sort(key=lambda t: t["updated_at"], reverse=True)
    
    for t in tasks:
        flags = []
        if t["is_active"]:
            flags.append("*")
        if t["is_stale"]:
            flags.append(f"stale:{t['stale_reason']}")
        if t["hash_mismatch"]:
            flags.append("hash-mismatch")
        
        flag_str = f" [{', '.join(flags)}]" if flags else ""
        print(f"{t['id']} | {t['state']} | {t['kind']} | {t['risk']} | {t['title']}{flag_str}")
    
    return 0


def cmd_select(args: argparse.Namespace) -> int:
    """Select a task as active."""
    task_id = args.id
    task_path = get_task_path(task_id)
    
    if not task_path.exists():
        print(f"error: task '{task_id}' not found", file=sys.stderr)
        return 1
    
    fm, body = parse_task_file(task_path)
    content = task_path.read_text(encoding="utf-8")
    
    stale, stale_reason = is_stale(
        fm.get("last_reviewed_at"),
        fm.get("updated_at"),
        fm.get("created_at", ""),
        fm.get("staleness_days_threshold", 21),
    )
    
    hash_ok, computed = verify_intent_hash(content, fm.get("intent_hash"))
    
    write_active_task(task_id)
    print(f"selected: {task_path}")
    
    if stale:
        print(f"warning: task is stale ({stale_reason})", file=sys.stderr)
    if not hash_ok:
        print("warning: intent hash mismatch - task may have drifted", file=sys.stderr)
    
    return 0


def cmd_close(args: argparse.Namespace) -> int:
    """Close a task."""
    task_id = args.id
    task_path = get_task_path(task_id)
    
    if not task_path.exists():
        print(f"error: task '{task_id}' not found", file=sys.stderr)
        return 1
    
    fm, body = parse_task_file(task_path)
    
    if fm.get("state") == "closed":
        print(f"error: task '{task_id}' is already closed", file=sys.stderr)
        return 1
    
    now = to_rfc3339(now_utc())
    
    fm["state"] = "closed"
    fm["close_reason"] = args.reason
    fm["closed_at"] = now
    fm["updated_at"] = now
    
    content = serialize_task(fm, body)
    intent_hash = compute_intent_hash(content)
    fm["intent_hash"] = intent_hash
    
    final_content = serialize_task(fm, body)
    task_path.write_text(final_content, encoding="utf-8")
    
    print(f"closed: {task_id} ({args.reason})")
    
    active_id = read_active_task()
    if active_id == task_id:
        write_active_task(None)
        print("cleared: .tasks/.active")
    
    return 0


def cmd_help(args: argparse.Namespace) -> int:
    """Show help information."""
    print("""task - Task management CLI

Commands:
  create    Create a new task
  list      List tasks with derived flags
  select    Select a task as active
  close     Close a task

  help      Show this help message
  validate  Verify CLI is runnable (read-only)

Usage:
  task create <id> [--title TITLE] [--kind KIND] [--risk RISK] [--goal GOAL] [--select]
  task list [--state STATE] [--stale]
  task select <id>
  task close <id> --reason {completed|abandoned}

Tasks are stored in .tasks/<id>.md
Active task is tracked in .tasks/.active
""")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Validate the CLI is runnable."""
    errors = []
    
    if importlib.util.find_spec("yaml") is None:
        errors.append("missing dependency: pyyaml")
    
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    
    print("ok: task CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="task", description="Task management CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    p_create = subparsers.add_parser("create", help="Create a new task")
    p_create.add_argument("id", help="Task ID (kebab-case)")
    p_create.add_argument("--title", help="Task title")
    p_create.add_argument("--kind", choices=["feature", "fix", "refactor", "docs", "chore", "spike"], default="feature")
    p_create.add_argument("--risk", choices=["low", "medium", "high"], default="low")
    p_create.add_argument("--goal", help="Initial goal text")
    p_create.add_argument("--select", action="store_true", help="Auto-select after creation")
    p_create.set_defaults(func=cmd_create)
    
    p_list = subparsers.add_parser("list", help="List tasks")
    p_list.add_argument("--state", choices=["draft", "open", "closed", "invalid"])
    p_list.add_argument("--stale", action="store_true", help="Show only stale tasks")
    p_list.set_defaults(func=cmd_list)
    
    p_select = subparsers.add_parser("select", help="Select a task as active")
    p_select.add_argument("id", help="Task ID to select")
    p_select.set_defaults(func=cmd_select)
    
    p_close = subparsers.add_parser("close", help="Close a task")
    p_close.add_argument("id", help="Task ID to close")
    p_close.add_argument("--reason", choices=["completed", "abandoned"], required=True)
    p_close.set_defaults(func=cmd_close)
    
    p_help = subparsers.add_parser("help", help="Show help")
    p_help.set_defaults(func=cmd_help)
    
    p_validate = subparsers.add_parser("validate", help="Verify CLI is runnable")
    p_validate.set_defaults(func=cmd_validate)
    
    args = parser.parse_args()
    
    if args.command is None:
        return cmd_help(args)
    
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
