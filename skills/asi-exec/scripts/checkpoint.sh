#!/usr/bin/env bash
set -euo pipefail

# asi-exec checkpoint script
# Validates execution state and gates progression
# Performs drift detection and state consistency checks

KICKOFF_DIR=".asi/kickoff"
PLAN_DIR=".asi/plan"
EXEC_DIR=".asi/exec"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
PARSED_FILE="$EXEC_DIR/PLAN_PARSED.json"
STATE_FILE="$EXEC_DIR/STATE.json"
RECEIPT_FILE="$EXEC_DIR/RECEIPT.md"

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  init              Verify initialization complete
  drift             Check for upstream artifact drift
  task-ready        Verify task can be executed (deps satisfied)
  task-complete     Verify task execution complete
  all-done          Verify all tasks complete
  state             Show current execution state

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: parse frontmatter field (strips surrounding quotes)
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    local value
    value=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//")
    # Strip surrounding quotes if present
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    echo "$value"
}

check_init() {
    echo "=== Checking initialization ===" >&2
    local failed=0
    
    if [[ ! -d "$EXEC_DIR" ]]; then
        echo "FAIL: $EXEC_DIR does not exist" >&2
        return 1
    fi
    echo "PASS: $EXEC_DIR exists" >&2
    
    if [[ ! -f "$PARSED_FILE" ]]; then
        echo "FAIL: $PARSED_FILE does not exist" >&2
        failed=1
    else
        echo "PASS: $PARSED_FILE exists" >&2
    fi
    
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "FAIL: $STATE_FILE does not exist" >&2
        failed=1
    else
        echo "PASS: $STATE_FILE exists" >&2
    fi
    
    if [[ $failed -eq 0 ]]; then
        echo "=== Initialization: PASSED ===" >&2
    else
        echo "=== Initialization: FAILED ===" >&2
    fi
    
    return $failed
}

check_drift() {
    echo "=== Checking for drift ===" >&2
    
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "FAIL: $STATE_FILE does not exist" >&2
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, skipping drift check" >&2
        return 0
    fi
    
    local failed=0
    
    # Check PLAN.md drift
    local stored_plan_hash
    stored_plan_hash=$(jq -r '.source_plan_hash // empty' "$STATE_FILE")
    
    if [[ -n "$stored_plan_hash" && -f "$PLAN_FILE" ]]; then
        local current_plan_hash
        current_plan_hash=$(sha256sum "$PLAN_FILE" | cut -d' ' -f1)
        
        if [[ "$stored_plan_hash" != "$current_plan_hash" ]]; then
            echo "FAIL: PLAN.md has changed (drift detected)" >&2
            failed=1
        else
            echo "PASS: PLAN.md unchanged" >&2
        fi
    fi
    
    # Check TODO.md drift
    local stored_todo_hash
    stored_todo_hash=$(jq -r '.source_todo_hash // empty' "$STATE_FILE")
    
    if [[ -n "$stored_todo_hash" && -f "$TODO_FILE" ]]; then
        local current_todo_hash
        current_todo_hash=$(sha256sum "$TODO_FILE" | cut -d' ' -f1)
        
        # TODO.md will change as we update statuses, so only warn
        if [[ "$stored_todo_hash" != "$current_todo_hash" ]]; then
            echo "INFO: TODO.md has been modified (expected during execution)" >&2
        fi
    fi
    
    if [[ $failed -eq 0 ]]; then
        echo "=== Drift check: PASSED ===" >&2
    else
        echo "=== Drift check: FAILED ===" >&2
    fi
    
    return $failed
}

check_task_ready() {
    echo "=== Checking task readiness ===" >&2
    
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "FAIL: $STATE_FILE does not exist" >&2
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is required" >&2
        return 1
    fi
    
    local current_task
    current_task=$(jq -r '.current_task // empty' "$STATE_FILE")
    
    if [[ -z "$current_task" ]]; then
        echo "INFO: No current task selected" >&2
        echo "Run scripts/select-task.sh first" >&2
        return 1
    fi
    
    echo "Current task: $current_task" >&2
    
    # Get task from PLAN_PARSED.json
    local task_status
    task_status=$(jq -r --arg id "$current_task" '.tasks[] | select(.id == $id) | .status' "$PARSED_FILE")
    
    if [[ "$task_status" == "done" ]]; then
        echo "INFO: Task $current_task is already done" >&2
        return 1
    fi
    
    echo "Task status: $task_status" >&2
    echo "=== Task ready: PASSED ===" >&2
    return 0
}

check_task_complete() {
    echo "=== Checking task completion ===" >&2
    
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "FAIL: $STATE_FILE does not exist" >&2
        return 1
    fi
    
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is required" >&2
        return 1
    fi
    
    local current_task
    current_task=$(jq -r '.current_task // empty' "$STATE_FILE")
    
    if [[ -z "$current_task" ]]; then
        # Check if any task was just completed
        local last_completed
        last_completed=$(jq -r '.completed_tasks[-1] // empty' "$STATE_FILE")
        
        if [[ -n "$last_completed" ]]; then
            echo "Last completed task: $last_completed" >&2
            echo "=== Task completion: PASSED ===" >&2
            return 0
        fi
        
        echo "INFO: No current or recently completed task" >&2
        return 1
    fi
    
    # Check if current task is marked done in TODO
    local task_status
    task_status=$(grep "| $current_task |" "$TODO_FILE" | awk -F'|' '{print $4}' | xargs)
    
    if [[ "$task_status" == "done" ]]; then
        echo "Task $current_task: done" >&2
        echo "=== Task completion: PASSED ===" >&2
        return 0
    else
        echo "Task $current_task: $task_status (expected: done)" >&2
        echo "=== Task completion: PENDING ===" >&2
        return 1
    fi
}

check_all_done() {
    echo "=== Checking all tasks ===" >&2
    
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist" >&2
        return 1
    fi
    
    local pending
    pending=$(grep -c '| pending |' "$TODO_FILE" 2>/dev/null || echo "0")
    local in_progress
    in_progress=$(grep -c '| in_progress |' "$TODO_FILE" 2>/dev/null || echo "0")
    local done_count
    done_count=$(grep -c '| done |' "$TODO_FILE" 2>/dev/null || echo "0")
    
    echo "Pending: $pending" >&2
    echo "In progress: $in_progress" >&2
    echo "Done: $done_count" >&2
    
    if [[ "$pending" -eq 0 && "$in_progress" -eq 0 ]]; then
        echo "=== All tasks: COMPLETE ===" >&2
        return 0
    else
        echo "=== All tasks: INCOMPLETE ===" >&2
        return 1
    fi
}

show_state() {
    echo "=== Current execution state ===" >&2
    
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "Not initialized. Run scripts/init.sh first." >&2
        return 1
    fi
    
    if command -v jq &>/dev/null; then
        jq '.' "$STATE_FILE"
    else
        cat "$STATE_FILE"
    fi
    
    return 0
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            init) check_init ;;
            drift) check_drift ;;
            task-ready) check_task_ready ;;
            task-complete) check_task_complete ;;
            all-done) check_all_done ;;
            state) show_state ;;
            *) echo "Unknown check: $2" >&2; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
