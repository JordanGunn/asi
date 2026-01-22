#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

cmd_help() {
    cat <<'EOF'
grep - Agent-assisted text search (deterministic ripgrep wrapper)

Commands:
  help                         Show this help message
  validate                     Verify the skill is runnable (read-only)
  run [opts]                   Execute a deterministic text search

Options (run):
  --root <path>                Root directory (default: .)
  --pattern <text>             Search pattern (repeatable)
  --glob <pattern>             Include glob (repeatable)
  --exclude <pattern>          Exclude glob (repeatable)
  --mode <fixed|regex>         Match mode (default: fixed)
  --case <sensitive|insensitive|smart>  Case behavior (default: smart)
  --context <n>                Lines of context (default: 0)
  --format <auto|human|jsonl>  Output format (default: auto)
  --max-lines <n>              Max output lines (default: 500)
  --max-files <n>              Stop after n files with matches
  --max-matches <n>            Stop after n total matches
  --parallelism <n>            Concurrent processes (default: 4)
  --hidden                     Include hidden files
  --follow                     Follow symlinks
  --no-ignore                  Ignore .gitignore rules
  --stdin                      Read plan JSON from stdin
EOF
}

cmd_validate() {
    local errors=0

    if ! command -v uv &>/dev/null; then
        echo "error: uv not found. Install from https://docs.astral.sh/uv/" >&2
        errors=$((errors + 1))
    fi

    if ! command -v rg &>/dev/null; then
        echo "error: rg not found. Install ripgrep." >&2
        errors=$((errors + 1))
    fi

    if [[ ! -f "$SRC_DIR/pyproject.toml" ]]; then
        echo "error: missing $SRC_DIR/pyproject.toml" >&2
        errors=$((errors + 1))
    fi

    if [[ ! -f "$SRC_DIR/cli.py" ]]; then
        echo "error: missing $SRC_DIR/cli.py" >&2
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    echo "ok: grep skill is runnable"
}

cmd_run() {
    cd "$SRC_DIR"
    uv run python cli.py run "$@"
}

case "${1:-help}" in
    help)
        cmd_help
        ;;
    validate)
        cmd_validate
        ;;
    run)
        shift
        cmd_run "$@"
        ;;
    *)
        echo "error: unknown command '$1'" >&2
        echo "run 'grep help' for usage" >&2
        exit 1
        ;;
esac
