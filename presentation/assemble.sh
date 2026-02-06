#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUT_FILE="${ROOT_DIR}/DECK.md"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

cat >"${tmp_file}" <<'EOF'
---
marp: true
title: Skills — Reliable, Auditable Agent Workflows
description: Skills overview for scientists and analysts
paginate: true
size: 16:9
---
EOF

# Assemble slides in numeric order (01_*.md, 02_*.md, ...)
shopt -s nullglob
slides=("${ROOT_DIR}"/[0-9][0-9]_*.md)
shopt -u nullglob

if [[ ${#slides[@]} -eq 0 ]]; then
  echo "No slides found in ${ROOT_DIR} (expected files like 01_Title.md)." >&2
  exit 1
fi

first=1
for slide in "${slides[@]}"; do
  {
    echo
    if [[ ${first} -eq 0 ]]; then
      echo "---"
      echo
    fi
    first=0
    cat "${slide}"
  } >>"${tmp_file}"
done

mv -f "${tmp_file}" "${OUT_FILE}"
echo "Wrote ${OUT_FILE}"
