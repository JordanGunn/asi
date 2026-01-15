#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"

# Source config if present
if [[ -f "$SCRIPT_DIR/.config.sh" ]]; then
    source "$SCRIPT_DIR/.config.sh"
fi

cmd_help() {
    cat <<EOF
task - Task management CLI

Commands:
  help      Show this help message
  validate  Verify the skill is runnable (read-only)
  clean     Remove generated artifacts (.tasks/)
  create    Create a new task
  list      List tasks with derived flags
  select    Select a task as active
  close     Close a task

Usage:
  task help
  task validate
  task clean [--dry-run]
  task create <id> [--title TITLE] [--kind KIND] [--risk RISK] [--select]
  task list [--state STATE] [--stale]
  task select <id>
  task close <id> --reason {completed|abandoned}

Tasks are stored in .tasks/<id>.md
Active task is tracked in .tasks/.active
EOF
}

cmd_validate() {
    local errors=0

    if ! command -v uv &>/dev/null; then
        echo "error: uv not found. Install from https://docs.astral.sh/uv/" >&2
        errors=$((errors + 1))
    fi

    if [[ ! -f "$INCLUDE_DIR/pyproject.toml" ]]; then
        echo "error: missing $INCLUDE_DIR/pyproject.toml" >&2
        errors=$((errors + 1))
    fi

    if [[ ! -f "$INCLUDE_DIR/task_cli.py" ]]; then
        echo "error: missing $INCLUDE_DIR/task_cli.py" >&2
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    echo "ok: task skill is runnable"
}

cmd_clean() {
    local dry_run=false
    if [[ "${1:-}" == "--dry-run" ]]; then
        dry_run=true
    fi

    local tasks_dir=".tasks"
    
    if [[ ! -d "$tasks_dir" ]]; then
        echo "nothing to clean: $tasks_dir does not exist"
        return 0
    fi

    if $dry_run; then
        echo "would remove: $tasks_dir"
    else
        rm -rf "$tasks_dir"
        echo "removed: $tasks_dir"
    fi
}

# Dispatch to Python CLI for other commands
cmd_dispatch() {
    cd "$INCLUDE_DIR"
    uv run python task_cli.py "$@"
}

case "${1:-help}" in
    help)
        cmd_help
        ;;
    validate)
        cmd_validate
        ;;
    clean)
        shift
        cmd_clean "$@"
        ;;
    create|list|select|close)
        cmd_dispatch "$@"
        ;;
    *)
        echo "error: unknown command '$1'" >&2
        echo "run 'task help' for usage" >&2
        exit 1
        ;;
esac
