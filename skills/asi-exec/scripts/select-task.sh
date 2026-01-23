#!/usr/bin/env bash
set -euo pipefail

# asi-exec task selection script
# Deterministically selects next task from TODO.md
# Validates dependencies before returning task

PLAN_DIR=".asi/plan"
EXEC_DIR=".asi/exec"
TODO_FILE="$PLAN_DIR/TODO.md"
PARSED_FILE="$EXEC_DIR/PLAN_PARSED.json"
STATE_FILE="$EXEC_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--task <task-id>]

Arguments:
  --task   Optional. Select specific task by ID (e.g., T001).
           If not provided, selects next pending task.

This script:
  1. Reads PLAN_PARSED.json for task list
  2. Finds next task (in_progress > pending, or specific --task)
  3. Validates task dependencies are satisfied
  4. Outputs task details as JSON
  5. Updates STATE.json with current task

Exit codes:
  0  Task selected successfully
  1  No tasks available or dependencies not met
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
TASK_ID=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task)
            TASK_ID="$2"
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

# Validate prerequisites
if [[ ! -f "$PARSED_FILE" ]]; then
    echo "ERROR: $PARSED_FILE does not exist. Run init.sh first." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required for task selection" >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get tasks from parsed file
TASKS=$(jq '.tasks' "$PARSED_FILE")

# Select task
if [[ -n "$TASK_ID" ]]; then
    # Find specific task
    TASK=$(echo "$TASKS" | jq --arg id "$TASK_ID" '.[] | select(.id == $id)')
    if [[ -z "$TASK" || "$TASK" == "null" ]]; then
        echo "ERROR: Task $TASK_ID not found" >&2
        exit 1
    fi
else
    # Find first in_progress task
    TASK=$(echo "$TASKS" | jq 'map(select(.status == "in_progress")) | first // empty')
    
    if [[ -z "$TASK" || "$TASK" == "null" ]]; then
        # Find first pending task
        TASK=$(echo "$TASKS" | jq 'map(select(.status == "pending")) | first // empty')
    fi
    
    if [[ -z "$TASK" || "$TASK" == "null" ]]; then
        echo "INFO: No pending tasks remaining" >&2
        cat << EOF
{
  "action": "asi-exec-select-task",
  "status": "all_done",
  "timestamp": "$TIMESTAMP",
  "message": "All tasks complete"
}
EOF
        exit 0
    fi
fi

# Extract task details
SELECTED_ID=$(echo "$TASK" | jq -r '.id')
SELECTED_STATUS=$(echo "$TASK" | jq -r '.status')
SELECTED_DEPS=$(echo "$TASK" | jq -r '.depends_on')
SELECTED_DESC=$(echo "$TASK" | jq -r '.description')
SELECTED_SOURCE=$(echo "$TASK" | jq -r '.source_section')

# Check if task is already done
if [[ "$SELECTED_STATUS" == "done" ]]; then
    echo "ERROR: Task $SELECTED_ID is already done" >&2
    exit 1
fi

# Validate dependencies
BLOCKED=false
BLOCKED_BY=""

if [[ -n "$SELECTED_DEPS" && "$SELECTED_DEPS" != "-" && "$SELECTED_DEPS" != "null" ]]; then
    # Parse dependencies (comma or space separated)
    IFS=', ' read -ra DEPS <<< "$SELECTED_DEPS"
    for dep in "${DEPS[@]}"; do
        dep=$(echo "$dep" | xargs)  # trim whitespace
        if [[ -z "$dep" ]]; then continue; fi
        
        # Check dependency status
        DEP_STATUS=$(echo "$TASKS" | jq -r --arg id "$dep" '.[] | select(.id == $id) | .status')
        if [[ "$DEP_STATUS" != "done" ]]; then
            BLOCKED=true
            if [[ -n "$BLOCKED_BY" ]]; then
                BLOCKED_BY="$BLOCKED_BY, $dep"
            else
                BLOCKED_BY="$dep"
            fi
        fi
    done
fi

if [[ "$BLOCKED" == true ]]; then
    echo "ERROR: Task $SELECTED_ID is blocked by: $BLOCKED_BY" >&2
    cat << EOF
{
  "action": "asi-exec-select-task",
  "status": "blocked",
  "timestamp": "$TIMESTAMP",
  "task_id": "$SELECTED_ID",
  "blocked_by": "$BLOCKED_BY",
  "message": "Dependencies not satisfied"
}
EOF
    exit 1
fi

# Update STATE.json
jq --arg task "$SELECTED_ID" --arg ts "$TIMESTAMP" \
    '.current_task = $task | .execution_log += [{"event": "task_selected", "task": $task, "timestamp": $ts}]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Emit task details
cat << EOF
{
  "action": "asi-exec-select-task",
  "status": "selected",
  "timestamp": "$TIMESTAMP",
  "task": {
    "id": "$SELECTED_ID",
    "description": "$SELECTED_DESC",
    "status": "$SELECTED_STATUS",
    "depends_on": "$SELECTED_DEPS",
    "source_section": "$SELECTED_SOURCE"
  },
  "next_action": "Execute task, then run scripts/update-status.sh --task $SELECTED_ID --status in_progress"
}
EOF
