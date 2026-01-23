#!/usr/bin/env bash
set -euo pipefail

# asi-exec status update script
# Deterministically updates task status in TODO.md
# Agent does not edit TODO.md directly

PLAN_DIR=".asi/plan"
EXEC_DIR=".asi/exec"
TODO_FILE="$PLAN_DIR/TODO.md"
PARSED_FILE="$EXEC_DIR/PLAN_PARSED.json"
STATE_FILE="$EXEC_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --task <task-id> --status <status>

Arguments:
  --task     Required. Task ID to update (e.g., T001).
  --status   Required. New status: pending, in_progress, or done.

This script:
  1. Validates task exists
  2. Updates task status in TODO.md
  3. Updates PLAN_PARSED.json
  4. Logs event to STATE.json
  5. Emits receipt

Exit codes:
  0  Status updated successfully
  1  Update failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
TASK_ID=""
NEW_STATUS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task)
            TASK_ID="$2"
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

if [[ -z "$TASK_ID" ]]; then
    echo "ERROR: --task is required" >&2
    usage
fi

if [[ -z "$NEW_STATUS" ]]; then
    echo "ERROR: --status is required" >&2
    usage
fi

if [[ ! "$NEW_STATUS" =~ ^(pending|in_progress|done)$ ]]; then
    echo "ERROR: Status must be pending, in_progress, or done" >&2
    usage
fi

# Validate prerequisites
if [[ ! -f "$TODO_FILE" ]]; then
    echo "ERROR: $TODO_FILE does not exist" >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Verify task exists in TODO.md
if ! grep -q "| $TASK_ID |" "$TODO_FILE"; then
    echo "ERROR: Task $TASK_ID not found in $TODO_FILE" >&2
    exit 1
fi

# Get current status
CURRENT_LINE=$(grep "| $TASK_ID |" "$TODO_FILE")
CURRENT_STATUS=$(echo "$CURRENT_LINE" | awk -F'|' '{print $4}' | xargs)

if [[ "$CURRENT_STATUS" == "$NEW_STATUS" ]]; then
    echo "INFO: Task $TASK_ID is already $NEW_STATUS" >&2
    cat << EOF
{
  "action": "asi-exec-update-status",
  "status": "no_change",
  "timestamp": "$TIMESTAMP",
  "task_id": "$TASK_ID",
  "task_status": "$NEW_STATUS"
}
EOF
    exit 0
fi

# Update TODO.md
# Replace the status in the task line
# Table format: | ID | Description | Status | Depends On | Source Section |
# Status is column 3 (0-indexed), we need to replace it
sed -i -E "s/^(\| ${TASK_ID} \|[^|]+\| )${CURRENT_STATUS}( \|)/\1${NEW_STATUS}\2/" "$TODO_FILE"

# Verify update
if ! grep -q "| ${TASK_ID} |.*| ${NEW_STATUS} |" "$TODO_FILE"; then
    echo "ERROR: Failed to update task status" >&2
    exit 1
fi

echo "Updated $TASK_ID: $CURRENT_STATUS → $NEW_STATUS" >&2

# Update PLAN_PARSED.json if it exists
if [[ -f "$PARSED_FILE" ]] && command -v jq &>/dev/null; then
    jq --arg id "$TASK_ID" --arg status "$NEW_STATUS" \
        '(.tasks[] | select(.id == $id)).status = $status' \
        "$PARSED_FILE" > "${PARSED_FILE}.tmp" && mv "${PARSED_FILE}.tmp" "$PARSED_FILE"
    
    # Update summary counts
    PENDING=$(jq '[.tasks[] | select(.status == "pending")] | length' "$PARSED_FILE")
    DONE=$(jq '[.tasks[] | select(.status == "done")] | length' "$PARSED_FILE")
    IN_PROGRESS=$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$PARSED_FILE")
    
    jq --argjson p "$PENDING" --argjson d "$DONE" \
        '.summary.pending = $p | .summary.done = $d' \
        "$PARSED_FILE" > "${PARSED_FILE}.tmp" && mv "${PARSED_FILE}.tmp" "$PARSED_FILE"
fi

# Update STATE.json
if [[ -f "$STATE_FILE" ]] && command -v jq &>/dev/null; then
    EVENT=$(jq -n \
        --arg event "status_changed" \
        --arg task "$TASK_ID" \
        --arg from "$CURRENT_STATUS" \
        --arg to "$NEW_STATUS" \
        --arg ts "$TIMESTAMP" \
        '{event: $event, task: $task, from: $from, to: $to, timestamp: $ts}')
    
    jq --argjson evt "$EVENT" '.execution_log += [$evt]' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    
    # If done, add to completed_tasks and clear current_task
    if [[ "$NEW_STATUS" == "done" ]]; then
        jq --arg task "$TASK_ID" \
            'if .current_task == $task then .current_task = null else . end | .completed_tasks += [$task] | .completed_tasks |= unique' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
    
    # If in_progress, set as current_task
    if [[ "$NEW_STATUS" == "in_progress" ]]; then
        jq --arg task "$TASK_ID" '.current_task = $task' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
fi

# Emit receipt
cat << EOF
{
  "action": "asi-exec-update-status",
  "status": "updated",
  "timestamp": "$TIMESTAMP",
  "task_id": "$TASK_ID",
  "previous_status": "$CURRENT_STATUS",
  "new_status": "$NEW_STATUS"
}
EOF
