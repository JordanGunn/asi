#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${ROOT_DIR}/dist"

mkdir -p "${DIST_DIR}"

"${ROOT_DIR}/assemble.sh"

if [[ ! -f "${ROOT_DIR}/package.json" ]]; then
  echo "Missing ${ROOT_DIR}/package.json. Run: (cd presentation && npm install)" >&2
  exit 1
fi

pushd "${ROOT_DIR}" >/dev/null

# Use local install if present; fallback to npx to be resilient.
if [[ -x "${ROOT_DIR}/node_modules/.bin/marp" ]]; then
  MARP_BIN="${ROOT_DIR}/node_modules/.bin/marp"
else
  MARP_BIN="npx --yes @marp-team/marp-cli"
fi

set +e
${MARP_BIN} --version >/dev/null 2>&1
version_ok=$?
set -e

if [[ ${version_ok} -ne 0 ]]; then
  echo "Marp CLI not available. Run: (cd presentation && npm install)" >&2
  exit 1
fi

# Build HTML and PDF. (PPTX support depends on Marp CLI version; see README.)
${MARP_BIN} "${ROOT_DIR}/DECK.md" --html --output "${DIST_DIR}/skills.html"
${MARP_BIN} "${ROOT_DIR}/DECK.md" --pdf --output "${DIST_DIR}/skills.pdf"

# Attempt PPTX export if supported by this Marp CLI.
set +e
${MARP_BIN} "${ROOT_DIR}/DECK.md" --pptx --output "${DIST_DIR}/skills.pptx" 2>/dev/null
pptx_status=$?
set -e

if [[ ${pptx_status} -ne 0 ]]; then
  echo "PPTX export not supported by this Marp CLI build. Generated ${DIST_DIR}/skills.html and ${DIST_DIR}/skills.pdf." >&2
  echo "If you need PPTX, consider Pandoc conversion or update Marp CLI; see presentation/README.md." >&2
else
  echo "Wrote ${DIST_DIR}/skills.pptx"
fi

popd >/dev/null

