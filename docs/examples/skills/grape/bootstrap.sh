#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/scripts/include"

if ! command -v uv &>/dev/null; then
    echo "error: uv not found. Install from https://docs.astral.sh/uv/" >&2
    exit 1
fi

if [[ ! -f "$INCLUDE_DIR/pyproject.toml" ]]; then
    echo "error: missing $INCLUDE_DIR/pyproject.toml" >&2
    exit 1
fi

cd "$INCLUDE_DIR"
uv sync

echo "ok: grape bootstrap complete"
