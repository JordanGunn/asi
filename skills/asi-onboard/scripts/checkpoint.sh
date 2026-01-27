#!/usr/bin/env bash
set -euo pipefail

# asi-onboard checkpoint script
# Validates completion of each step before allowing progression.

TARGET_DIR="${TARGET_DIR:-}"
if [[ -z "${TARGET_DIR}" ]]; then
  if TARGET_DIR=$(git rev-parse --show-toplevel 2>/dev/null); then
    :
  else
    TARGET_DIR="."
  fi
fi
cd "$TARGET_DIR"

ASI_DIR=".asi/onboard"
NOTES_FILE="$ASI_DIR/NOTES.md"
SOURCES_FILE="$ASI_DIR/SOURCES.md"
STATE_FILE="$ASI_DIR/STATE.json"

usage() {
  cat <<EOF
Usage: $(basename "$0") --step <step-number> [--advance]

Arguments:
  --step     Required. Step number to validate (1-3).
  --advance  Optional. If validation passes, advance state to next step.
EOF
  exit 2
}

STEP=""
ADVANCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --step) STEP="${2:-}"; shift 2 ;;
    --advance) ADVANCE=1; shift ;;
    -h|--help) usage ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage ;;
  esac
done

if [[ -z "$STEP" ]]; then
  usage
fi

if [[ ! -f "$NOTES_FILE" || ! -f "$SOURCES_FILE" || ! -f "$STATE_FILE" ]]; then
  echo "FAIL: Onboarding artifacts missing. Run scripts/init.sh first." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "WARN: jq not available; checkpoint will do minimal validation" >&2
else
  if ! jq -e '.current_step >= 0' "$STATE_FILE" >/dev/null 2>&1; then
    echo "FAIL: STATE.json is not valid JSON or missing required fields" >&2
    exit 1
  fi
fi

if ! grep -q "^### Step ${STEP} — " "$NOTES_FILE"; then
  echo "FAIL: NOTES.md does not contain injected entry for step ${STEP}" >&2
  exit 1
fi

echo "PASS: Step ${STEP} appears injected into NOTES.md"

if [[ $ADVANCE -eq 1 ]]; then
  if command -v jq >/dev/null 2>&1; then
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    tmp_state="${STATE_FILE}.tmp"
    jq --arg step "$STEP" --arg ts "$ts" \
      '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
      "$STATE_FILE" > "$tmp_state" && mv "$tmp_state" "$STATE_FILE"
    echo "PASS: STATE.json advanced to step ${STEP}"
  else
    echo "WARN: jq not available; cannot advance STATE.json" >&2
  fi
fi

exit 0

