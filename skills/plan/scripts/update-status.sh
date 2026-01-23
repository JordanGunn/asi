#!/usr/bin/env bash
set -euo pipefail

# plan skill - update-status.sh
# Updates the status of a step

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <step-id> --status <status>

Arguments:
  --step     Required. Step ID (e.g., S001).
  --status   Required. New status: pending, in_progress, done, skipped.

Exit codes:
  0  Status updated successfully
  1  Update failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
STEP_ID=""
NEW_STATUS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --step)
            STEP_ID="$2"
            shift 2
            ;;
        --status)
            NEW_STATUS="$2"
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

if [[ -z "$STEP_ID" ]]; then
    echo "ERROR: --step is required" >&2
    usage
fi

if [[ -z "$NEW_STATUS" ]]; then
    echo "ERROR: --status is required" >&2
    usage
fi

if [[ ! "$NEW_STATUS" =~ ^(pending|in_progress|done|skipped)$ ]]; then
    echo "ERROR: Invalid status. Must be: pending, in_progress, done, skipped" >&2
    exit 1
fi

# Check prerequisites
if [[ ! -f "$ACTIVE_FILE" ]]; then
    echo "ERROR: No active plan." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check if step exists
if ! grep -q "id: \"*${STEP_ID}\"*" "$ACTIVE_FILE"; then
    echo "ERROR: Step $STEP_ID not found" >&2
    exit 1
fi

# Update status using sed (works without yq)
sed -i -E "/id: \"*${STEP_ID}\"*/,/^[[:space:]]*-|^[[:space:]]*$/{s/(status:).*/\1 ${NEW_STATUS}/}" "$ACTIVE_FILE"

# Add completed_at if done
if [[ "$NEW_STATUS" == "done" ]]; then
    # Check if completed_at already exists for this step
    if ! sed -n "/id: \"*${STEP_ID}\"*/,/^[[:space:]]*-|^$/p" "$ACTIVE_FILE" | grep -q "completed_at:"; then
        sed -i -E "/id: \"*${STEP_ID}\"*/,/status:/{/status:/a\\    completed_at: \"${TIMESTAMP}\"
}" "$ACTIVE_FILE"
    fi
fi

# Update state
if [[ -f "$STATE_FILE" ]] && command -v jq &>/dev/null; then
    jq --arg ts "$TIMESTAMP" --arg id "$STEP_ID" --arg status "$NEW_STATUS" \
        '.last_modified = $ts | .log += [{"event": "status_changed", "step_id": $id, "new_status": $status, "timestamp": $ts}]' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

cat << EOF
{
  "action": "plan-update-status",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "step_id": "$STEP_ID",
  "new_status": "$NEW_STATUS",
  "message": "Step $STEP_ID updated to $NEW_STATUS"
}
EOF
