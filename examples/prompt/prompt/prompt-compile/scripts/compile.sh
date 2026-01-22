#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"

if [[ -f "$SCRIPT_DIR/.config.sh" ]]; then
    source "$SCRIPT_DIR/.config.sh"
fi

PYTHONPATH="$INCLUDE_DIR" uv run --project "$INCLUDE_DIR" python "$INCLUDE_DIR/prompt_compile_cli.py" "$@"
