#!/usr/bin/env bash
set -euo pipefail

# asi-onboard bootstrap script
# Read-only environment checks

usage() {
  cat <<EOF
Usage: $(basename "$0") --check

Checks:
  - jq is installed (recommended)
  - git is available (optional; used to locate repo root)
EOF
  exit 2
}

if [[ "${1:-}" != "--check" ]]; then
  usage
fi

missing=0

if command -v jq >/dev/null 2>&1; then
  echo "PASS: jq found ($(command -v jq))"
else
  echo "WARN: jq not found (recommended for JSON handling)"
  missing=1
fi

if command -v git >/dev/null 2>&1; then
  echo "PASS: git found ($(command -v git))"
else
  echo "WARN: git not found (repo root detection may be limited)"
fi

if [[ $missing -eq 0 ]]; then
  echo "PASS: bootstrap checks complete"
  exit 0
fi

echo "WARN: bootstrap checks found missing recommended tooling"
exit 0

