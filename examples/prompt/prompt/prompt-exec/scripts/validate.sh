#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"

errors=0

if ! command -v uv &>/dev/null; then
    echo "error: uv not found. Install from https://docs.astral.sh/uv/" >&2
    errors=$((errors + 1))
fi

if [[ ! -f "$INCLUDE_DIR/pyproject.toml" ]]; then
    echo "error: missing $INCLUDE_DIR/pyproject.toml" >&2
    errors=$((errors + 1))
fi

if [[ ! -f "$INCLUDE_DIR/prompt_exec_cli.py" ]]; then
    echo "error: missing $INCLUDE_DIR/prompt_exec_cli.py" >&2
    errors=$((errors + 1))
fi

if [[ $errors -gt 0 ]]; then
    exit 1
fi

echo "ok: prompt-exec skill is runnable"
