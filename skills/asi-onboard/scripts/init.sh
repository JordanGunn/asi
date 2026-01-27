#!/usr/bin/env bash
set -euo pipefail

# asi-onboard init script
# Creates disk-backed onboarding artifacts and lifecycle state (idempotent).

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

TEMPLATE_NOTES="skills/asi-onboard/assets/templates/NOTES.template.md"
TEMPLATE_SOURCES="skills/asi-onboard/assets/templates/SOURCES.template.md"

TOPIC="repo-context"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--topic "<topic>"]

Arguments:
  --topic   Optional. Short topic label for onboarding notes.

Creates/updates:
  - $NOTES_FILE
  - $SOURCES_FILE
  - $STATE_FILE
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --topic)
      TOPIC="${2:-}"
      if [[ -z "$TOPIC" ]]; then
        echo "ERROR: --topic requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage
      ;;
  esac
done

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$ASI_DIR"

  render_template() {
    local template="$1"
    local out="$2"
    local topic="$3"

    sed \
    -e 's/\${timestamp}/'"$TIMESTAMP"'/g' \
    -e 's/\${topic}/'"$topic"'/g' \
    "$template" > "$out"
  }

if [[ ! -f "$NOTES_FILE" ]]; then
  render_template "$TEMPLATE_NOTES" "$NOTES_FILE" "$TOPIC"
else
  # Reconcile in case a previous run left placeholders unrendered.
  if grep -Fq '${timestamp}' "$NOTES_FILE" 2>/dev/null || grep -Fq '${topic}' "$NOTES_FILE" 2>/dev/null; then
    render_template "$TEMPLATE_NOTES" "$NOTES_FILE" "$TOPIC"
  fi
fi

if [[ ! -f "$SOURCES_FILE" ]]; then
  render_template "$TEMPLATE_SOURCES" "$SOURCES_FILE" "$TOPIC"
else
  if grep -Fq '${timestamp}' "$SOURCES_FILE" 2>/dev/null || grep -Fq '${topic}' "$SOURCES_FILE" 2>/dev/null; then
    render_template "$TEMPLATE_SOURCES" "$SOURCES_FILE" "$TOPIC"
  fi
fi

if [[ ! -f "$STATE_FILE" ]]; then
  cat > "$STATE_FILE" <<EOF
{
  "topic": "${TOPIC}",
  "initialized_at": "${TIMESTAMP}",
  "current_step": 0,
  "steps": {
    "0": { "name": "init", "status": "complete", "completed_at": "${TIMESTAMP}" },
    "1": { "name": "entrypoints", "status": "pending", "completed_at": null },
    "2": { "name": "deepening", "status": "pending", "completed_at": null },
    "3": { "name": "handoff", "status": "pending", "completed_at": null }
  }
}
EOF
fi

cat <<EOF
{
  "action": "asi-onboard-init",
  "status": "complete",
  "timestamp": "${TIMESTAMP}",
  "topic": "${TOPIC}",
  "target_directory": "$(pwd)",
  "created_or_verified": [
    "${NOTES_FILE}",
    "${SOURCES_FILE}",
    "${STATE_FILE}"
  ],
  "next_step": 1,
  "next_action": "Read entrypoints, then write .asi/onboard/step_1_output.json and run: scripts/inject.sh --step 1 --input .asi/onboard/step_1_output.json"
}
EOF
