#!/usr/bin/env bash
set -euo pipefail

# asi-exec receipt append script
# Deterministically appends execution receipt to RECEIPT.md
# Agent produces receipt JSON; script writes to file

EXEC_DIR=".asi/exec"
RECEIPT_FILE="$EXEC_DIR/RECEIPT.md"
STATE_FILE="$EXEC_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --input <json-file>

Arguments:
  --input   Required. Path to receipt JSON file conforming to exec_receipt_v1.schema.json.

This script:
  1. Validates receipt JSON
  2. Formats receipt as markdown
  3. Appends to RECEIPT.md
  4. Logs event to STATE.json
  5. Emits confirmation

Exit codes:
  0  Receipt appended successfully
  1  Append failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
INPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)
            INPUT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            ;;
    esac
done

if [[ -z "$INPUT" ]]; then
    echo "ERROR: --input is required" >&2
    usage
fi

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input file does not exist: $INPUT" >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required. Run scripts/bootstrap.sh --check for install guidance." >&2
    exit 1
fi

# Validate receipt has required fields
TASK_ID=$(jq -r '.task_id // empty' "$INPUT")
STATUS=$(jq -r '.status // empty' "$INPUT")
TIMESTAMP=$(jq -r '.timestamp // empty' "$INPUT")

if [[ -z "$TASK_ID" ]]; then
    echo "ERROR: Receipt missing task_id" >&2
    exit 1
fi

if [[ -z "$STATUS" ]]; then
    echo "ERROR: Receipt missing status" >&2
    exit 1
fi

if [[ -z "$TIMESTAMP" ]]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
fi

# Extract optional fields
ARTIFACTS_CREATED=$(jq -r '.artifacts_created // [] | join(", ")' "$INPUT")
ARTIFACTS_MODIFIED=$(jq -r '.artifacts_modified // [] | join(", ")' "$INPUT")
ERROR_MSG=$(jq -r '.error // ""' "$INPUT")
NOTES=$(jq -r '.notes // ""' "$INPUT")

# Create RECEIPT.md if it doesn't exist
if [[ ! -f "$RECEIPT_FILE" ]]; then
    mkdir -p "$EXEC_DIR"
    cat > "$RECEIPT_FILE" << EOF
---
description: "Execution receipts"
timestamp: "${TIMESTAMP}"
---

# Execution Receipts

## Log

EOF
fi

# Format receipt entry
ENTRY="### $TASK_ID — $STATUS

- **Timestamp:** $TIMESTAMP"

if [[ -n "$ARTIFACTS_CREATED" ]]; then
    ENTRY+="
- **Created:** $ARTIFACTS_CREATED"
fi

if [[ -n "$ARTIFACTS_MODIFIED" ]]; then
    ENTRY+="
- **Modified:** $ARTIFACTS_MODIFIED"
fi

if [[ -n "$ERROR_MSG" ]]; then
    ENTRY+="
- **Error:** $ERROR_MSG"
fi

if [[ -n "$NOTES" ]]; then
    ENTRY+="
- **Notes:** $NOTES"
fi

ENTRY+="

---
"

# Append to RECEIPT.md
echo "$ENTRY" >> "$RECEIPT_FILE"

echo "Appended receipt for $TASK_ID to $RECEIPT_FILE" >&2

# Log to STATE.json
if [[ -f "$STATE_FILE" ]]; then
    EVENT=$(jq -n \
        --arg event "receipt_appended" \
        --arg task "$TASK_ID" \
        --arg status "$STATUS" \
        --arg ts "$TIMESTAMP" \
        '{event: $event, task: $task, status: $status, timestamp: $ts}')
    
    jq --argjson evt "$EVENT" '.execution_log += [$evt]' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

# Emit confirmation
cat << EOF
{
  "action": "asi-exec-append-receipt",
  "status": "appended",
  "timestamp": "$TIMESTAMP",
  "task_id": "$TASK_ID",
  "task_status": "$STATUS",
  "receipt_file": "$RECEIPT_FILE"
}
EOF
