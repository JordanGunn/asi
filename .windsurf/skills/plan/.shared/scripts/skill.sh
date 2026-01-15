#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"

cmd_help() {
    cd "$INCLUDE_DIR"
    uv run python plan_cli.py help
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

    if [[ ! -f "$INCLUDE_DIR/plan_cli.py" ]]; then
        echo "error: missing $INCLUDE_DIR/plan_cli.py" >&2
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    echo "ok: plan skill is runnable"
}

cmd_dispatch() {
    cd "$INCLUDE_DIR"
    uv run python plan_cli.py "$@"
}

case "${1:-help}" in
    help)
        cmd_help
        ;;
    validate)
        cmd_validate
        ;;
    list|status|next|init|surface|clean)
        cmd_dispatch "$@"
        ;;
    *)
        echo "error: unknown command '$1'" >&2
        echo "run 'plan help' for usage" >&2
        exit 1
        ;;
esac
