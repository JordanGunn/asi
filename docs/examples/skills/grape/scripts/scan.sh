#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"
VENV_DIR="$INCLUDE_DIR/.venv"

if [[ ! -d "$VENV_DIR" ]]; then
    echo "error: missing venv at $VENV_DIR (run $(cd "$SCRIPT_DIR/.." && pwd)/bootstrap.sh)" >&2
    exit 1
fi

cd "$INCLUDE_DIR"
uv run python grape_cli.py scan "$@"
