#!/usr/bin/env bash
set -euo pipefail

# asi-exec validation script
# Read-only deterministic checks for exec artifacts

KICKOFF_DIR=".asi/kickoff"
PLAN_DIR=".asi/plan"
EXEC_DIR=".asi/exec"
SCAFFOLD_FILE="$KICKOFF_DIR/SCAFFOLD.json"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
RECEIPT_FILE="$EXEC_DIR/RECEIPT.md"
LOCK_FILE="$EXEC_DIR/.lock"

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  prereqs           All prerequisites for asi-exec
  plan-approved     PLAN.md status == approved
  todo-exists       TODO.md exists
  scaffold-exists   SCAFFOLD.json exists
  task-pending      Pending tasks exist in TODO.md
  task-next         Show next pending task
  todo-complete     All tasks status == done
  scaffold-complete All SCAFFOLD.json paths exist on disk
  receipt-exists    RECEIPT.md exists
  lock-check        Check execution lock status
  lock-acquire      Acquire execution lock
  lock-release      Release execution lock
  archive           Archive .asi/ to .asi-archive/
  all               Run all checks

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: parse frontmatter field
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//"
}

check_prereqs() {
    local failed=0
    echo "=== asi-exec prerequisites ==="
    
    if [[ ! -d "$PLAN_DIR" ]]; then
        echo "FAIL: $PLAN_DIR does not exist"
        failed=1
    else
        echo "PASS: $PLAN_DIR exists"
    fi
    
    check_plan_approved || failed=1
    check_todo_exists || failed=1
    check_scaffold_exists || failed=1
    
    if [[ ! -d "$EXEC_DIR" ]]; then
        mkdir -p "$EXEC_DIR"
        echo "PASS: Created $EXEC_DIR"
    else
        echo "PASS: $EXEC_DIR exists"
    fi
    
    echo "==="
    return $failed
}

check_plan_approved() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$PLAN_FILE" "status")
    if [[ "$status" == "approved" ]]; then
        echo "PASS: PLAN.md status=approved"
        return 0
    else
        echo "FAIL: PLAN.md status=$status (expected: approved)"
        return 1
    fi
}

check_todo_exists() {
    if [[ -f "$TODO_FILE" ]]; then
        echo "PASS: $TODO_FILE exists"
        return 0
    else
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
}

check_scaffold_exists() {
    if [[ -f "$SCAFFOLD_FILE" ]]; then
        echo "PASS: $SCAFFOLD_FILE exists"
        return 0
    else
        echo "FAIL: $SCAFFOLD_FILE does not exist"
        return 1
    fi
}

check_task_pending() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    local pending
    pending=$(grep -c '| pending |' "$TODO_FILE" 2>/dev/null || echo "0")
    local in_progress
    in_progress=$(grep -c '| in_progress |' "$TODO_FILE" 2>/dev/null || echo "0")
    if [[ "$pending" -gt 0 || "$in_progress" -gt 0 ]]; then
        echo "PASS: $pending pending, $in_progress in_progress"
        return 0
    else
        echo "FAIL: No pending tasks"
        return 1
    fi
}

check_task_next() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    # Find first in_progress task, or first pending task
    local next_task
    next_task=$(grep '| in_progress |' "$TODO_FILE" | head -1)
    if [[ -z "$next_task" ]]; then
        next_task=$(grep '| pending |' "$TODO_FILE" | head -1)
    fi
    if [[ -n "$next_task" ]]; then
        local task_id
        task_id=$(echo "$next_task" | awk -F'|' '{print $2}' | xargs)
        echo "NEXT: $task_id"
        return 0
    else
        echo "DONE: No tasks remaining"
        return 1
    fi
}

check_todo_complete() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    local pending
    pending=$(grep -c '| pending |' "$TODO_FILE" 2>/dev/null || echo "0")
    local in_progress
    in_progress=$(grep -c '| in_progress |' "$TODO_FILE" 2>/dev/null || echo "0")
    if [[ "$pending" -eq 0 && "$in_progress" -eq 0 ]]; then
        echo "PASS: All tasks complete"
        return 0
    else
        echo "FAIL: $pending pending, $in_progress in_progress"
        return 1
    fi
}

check_scaffold_complete() {
    if [[ ! -f "$SCAFFOLD_FILE" ]]; then
        echo "FAIL: $SCAFFOLD_FILE does not exist"
        return 1
    fi
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, skipping scaffold verification"
        return 0
    fi
    local failed=0
    # Check if grouped or single
    local skill_type
    if [[ -f "$KICKOFF_DIR/SKILL_TYPE.json" ]]; then
        skill_type=$(jq -r '.type // "single"' "$KICKOFF_DIR/SKILL_TYPE.json")
    else
        skill_type="single"
    fi
    
    if [[ "$skill_type" == "grouped" ]]; then
        # Check sub_skills directories
        jq -r '.sub_skills[].name' "$SCAFFOLD_FILE" 2>/dev/null | while read -r name; do
            local target
            target=$(jq -r '.target_directory' "$SCAFFOLD_FILE")
            if [[ ! -d "$target/$name" ]]; then
                echo "FAIL: Missing directory $target/$name"
                failed=1
            fi
        done
    else
        # Check single skill directories
        jq -r '.structure.directories[]' "$SCAFFOLD_FILE" 2>/dev/null | while read -r dir; do
            local target
            target=$(jq -r '.target_directory' "$SCAFFOLD_FILE")
            if [[ ! -d "$target/$dir" ]]; then
                echo "FAIL: Missing directory $target/$dir"
                failed=1
            fi
        done
    fi
    
    if [[ "$failed" -eq 0 ]]; then
        echo "PASS: Scaffold directories exist"
    fi
    return $failed
}

check_receipt_exists() {
    if [[ -f "$RECEIPT_FILE" ]]; then
        echo "PASS: $RECEIPT_FILE exists"
        return 0
    else
        echo "FAIL: $RECEIPT_FILE does not exist"
        return 1
    fi
}

check_lock() {
    if [[ ! -f "$LOCK_FILE" ]]; then
        echo "PASS: No lock - execution allowed"
        return 0
    fi
    local stale_threshold=3600
    local lock_age
    lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || stat -f %m "$LOCK_FILE")))
    if [[ $lock_age -gt $stale_threshold ]]; then
        echo "WARN: Stale lock (age: ${lock_age}s)"
        return 0
    fi
    echo "FAIL: Locked (age: ${lock_age}s)"
    return 1
}

acquire_lock() {
    mkdir -p "$EXEC_DIR"
    if [[ -f "$LOCK_FILE" ]]; then
        local stale_threshold=3600
        local lock_age
        lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || stat -f %m "$LOCK_FILE")))
        if [[ $lock_age -le $stale_threshold ]]; then
            echo "FAIL: Cannot acquire lock"
            return 1
        fi
    fi
    echo "timestamp: $(date -Iseconds)" > "$LOCK_FILE"
    echo "PASS: Lock acquired"
    return 0
}

release_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
    echo "PASS: Lock released"
    return 0
}

do_archive() {
    if [[ ! -d ".asi" ]]; then
        echo "FAIL: .asi/ does not exist"
        return 1
    fi
    local archive_dir=".asi-archive/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$archive_dir"
    mv .asi/* "$archive_dir/"
    rmdir .asi
    echo "PASS: Archived to $archive_dir"
    return 0
}

check_all() {
    local failed=0
    echo "=== asi-exec validation ==="
    check_prereqs || failed=1
    check_task_pending || true  # Not a failure if no tasks
    check_task_next || true
    echo "==="
    return $failed
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            prereqs) check_prereqs ;;
            plan-approved) check_plan_approved ;;
            todo-exists) check_todo_exists ;;
            scaffold-exists) check_scaffold_exists ;;
            task-pending) check_task_pending ;;
            task-next) check_task_next ;;
            todo-complete) check_todo_complete ;;
            scaffold-complete) check_scaffold_complete ;;
            receipt-exists) check_receipt_exists ;;
            lock-check) check_lock ;;
            lock-acquire) acquire_lock ;;
            lock-release) release_lock ;;
            archive) do_archive ;;
            all) check_all ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
