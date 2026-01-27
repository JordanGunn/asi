#!/usr/bin/env bash
set -euo pipefail

# asi-onboard inject script
# Appends step output into NOTES.md and SOURCES.md (deterministic file writing).

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
Usage: $(basename "$0") --step <step-number> --input <json-file>

Arguments:
  --step   Required. Step number (1-3).
  --input  Required. Path to JSON file conforming to step schema.
EOF
  exit 2
}

STEP=""
INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --step) STEP="${2:-}"; shift 2 ;;
    --input) INPUT="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage ;;
  esac
done

if [[ -z "$STEP" || -z "$INPUT" ]]; then
  usage
fi

if [[ ! -f "$INPUT" ]]; then
  echo "ERROR: Input JSON does not exist: $INPUT" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required for injection" >&2
  echo "INFO: Run scripts/bootstrap.sh --check" >&2
  exit 1
fi

if [[ ! -f "$NOTES_FILE" || ! -f "$SOURCES_FILE" || ! -f "$STATE_FILE" ]]; then
  echo "ERROR: Onboarding artifacts not initialized. Run scripts/init.sh first." >&2
  exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

summary=$(jq -r '.output.summary' "$INPUT")
reasoning=$(jq -r '.reasoning_trace // ""' "$INPUT")

read_rows=$(jq -r '.output.read[] | "| `\(.path)` | \(.why) | \(.notes // "-") |"' "$INPUT" 2>/dev/null || true)
key_points=$(jq -r '.output.key_points[]? | "- " + .' "$INPUT" 2>/dev/null || true)
open_questions=$(jq -r '.output.open_questions[]? | "- " + .' "$INPUT" 2>/dev/null || true)
next_actions=$(jq -r '.output.next_actions[]? | "- " + .' "$INPUT" 2>/dev/null || true)

{
  echo ""
  echo "### Step ${STEP} — ${TIMESTAMP}"
  echo ""
  echo "**Summary**"
  echo ""
  echo "$summary"
  echo ""
  if [[ -n "$key_points" ]]; then
    echo "**Key points**"
    echo ""
    echo "$key_points"
    echo ""
  fi
  if [[ -n "$open_questions" ]]; then
    echo "**Open questions**"
    echo ""
    echo "$open_questions"
    echo ""
  fi
  if [[ -n "$next_actions" ]]; then
    echo "**Next actions**"
    echo ""
    echo "$next_actions"
    echo ""
  fi
  if [[ -n "$reasoning" && "$reasoning" != "null" ]]; then
    echo "**Reasoning trace**"
    echo ""
    echo "$reasoning"
    echo ""
  fi
} >> "$NOTES_FILE"

if [[ -n "$read_rows" ]]; then
  {
    echo "$read_rows"
  } >> "$SOURCES_FILE"
fi

tmp_state="${STATE_FILE}.tmp"
jq --arg step "$STEP" --arg ts "$TIMESTAMP" \
  '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
  "$STATE_FILE" > "$tmp_state" && mv "$tmp_state" "$STATE_FILE"

cat <<EOF
{
  "action": "asi-onboard-inject",
  "status": "complete",
  "timestamp": "${TIMESTAMP}",
  "step": ${STEP},
  "input": "${INPUT}",
  "updated": [
    "${NOTES_FILE}",
    "${SOURCES_FILE}",
    "${STATE_FILE}"
  ]
}
EOF

