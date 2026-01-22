#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

cmd_help() {
    cat <<'EOF'
re - Agent-assisted pattern matching (deterministic regex execution)

Commands:
  help                         Show this help message
  validate                     Verify the skill is runnable (read-only)
  run [opts]                   Execute a deterministic regex match

Options (run):
  --pattern <regex>            Regex pattern to match
  --input <text>               Input text to match against
  --file <path>                Read input from file
  --ignore-case                Case insensitive matching
  --multiline                  ^ and $ match line boundaries
  --dotall                     . matches newlines
  --max-matches <n>            Max matches (default: 1000)
  --timeout <n>                Timeout in seconds (default: 30)
  --format <auto|human|jsonl>  Output format (default: auto)
  --stdin                      Read plan JSON from stdin
EOF
}

cmd_validate() {
    local errors=0

    if ! command -v uv &>/dev/null; then
        echo "error: uv not found. Install from https://docs.astral.sh/uv/" >&2
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

    echo "ok: re skill is runnable"
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
        echo "run 're help' for usage" >&2
        exit 1
        ;;
esac
