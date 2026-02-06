#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cli_dir="${script_dir}/cli"

if [[ ! -d "${cli_dir}" ]]; then
    echo "error: cli directory not found at ${cli_dir}" >&2
    exit 1
fi

if command -v uv >/dev/null 2>&1; then
    if uv tool install -e "${cli_dir}"; then
        exit 0
    fi
    echo "warning: uv install failed; falling back to pip." >&2
fi

for py in python python3; do
    if command -v "${py}" >/dev/null 2>&1; then
        "${py}" -m pip install -e "${cli_dir}"
        exit 0
    fi
done

echo "error: python not found (tried python, python3)." >&2
exit 1
