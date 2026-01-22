#!/usr/bin/env bash
set -euo pipefail

# asi-exec validation script
# Read-only checks for skill preconditions

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  plan-approved     Check if PLAN.md exists with status: approved
  plan-drift        Check if PLAN.md has changed since TODO.md was created
  todo              Check if TODO.md exists and has valid frontmatter
  task-pending      Check if there are pending tasks in TODO.md
  deps-satisfied    Check if dependencies are satisfied for next task
  lock-check        Check if execution lock exists (for concurrency)
  lock-acquire      Acquire execution lock
  lock-release      Release execution lock

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

check_plan_approved() {
    local plan_file="${TARGET_DIR:-./PLAN.md}"
    
    if [[ ! -f "$plan_file" ]]; then
        echo "PLAN.md not found"
        exit 1
    fi
    
    if ! head -1 "$plan_file" | grep -q '^---$'; then
        echo "PLAN.md missing frontmatter"
        exit 1
    fi
    
    if ! grep -q '^status: approved' "$plan_file"; then
        local status=$(grep '^status:' "$plan_file" | head -1 | cut -d':' -f2 | tr -d ' ')
        echo "PLAN.md status is '${status}', not 'approved'"
        exit 1
    fi
    
    echo "PLAN.md exists with status: approved"
    exit 0
}

check_plan_drift() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    local plan_file="${TARGET_DIR:-./PLAN.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    if [[ ! -f "$plan_file" ]]; then
        echo "PLAN.md not found"
        exit 1
    fi
    
    local stored_hash=$(grep '^source_plan_hash:' "$todo_file" | head -1 | cut -d'"' -f2)
    if [[ -z "$stored_hash" ]]; then
        echo "TODO.md missing source_plan_hash field"
        exit 1
    fi
    
    local current_hash=$(sha256sum "$plan_file" | cut -d' ' -f1)
    
    if [[ "$stored_hash" != "$current_hash" ]]; then
        echo "PLAN.md has changed since TODO.md was created (drift detected)"
        echo "  Stored hash:  $stored_hash"
        echo "  Current hash: $current_hash"
        exit 1
    fi
    
    echo "PLAN.md unchanged (no drift)"
    exit 0
}

check_todo() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    if ! head -1 "$todo_file" | grep -q '^---$'; then
        echo "TODO.md missing frontmatter"
        exit 1
    fi
    
    if ! grep -q '^status:' "$todo_file"; then
        echo "TODO.md missing status field"
        exit 1
    fi
    
    echo "TODO.md exists with valid frontmatter"
    exit 0
}

check_task_pending() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    # Look for tasks with status pending, in_progress, or blocked
    if grep -qE '^\|[[:space:]]*T[0-9]+.*\|[[:space:]]*(pending|in_progress|blocked)[[:space:]]*\|' "$todo_file"; then
        echo "Pending tasks found"
        exit 0
    fi
    
    echo "No pending tasks (all done or no tasks)"
    exit 1
}

check_deps_satisfied() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    # This is a simplified check - full dependency analysis requires parsing
    # For now, just verify TODO.md is readable
    echo "Dependency check requires task context (use agent reasoning)"
    exit 0
}

check_lock() {
    local lock_file="${TARGET_DIR:-.}/.asi-exec.lock"
    local stale_threshold=3600  # 1 hour in seconds
    
    if [[ ! -f "$lock_file" ]]; then
        echo "No lock file - execution allowed"
        exit 0
    fi
    
    # Check if lock is stale
    local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || stat -f %m "$lock_file")))
    
    if [[ $lock_age -gt $stale_threshold ]]; then
        echo "Stale lock detected (age: ${lock_age}s) - removing"
        rm -f "$lock_file"
        exit 0
    fi
    
    echo "Execution locked (age: ${lock_age}s)"
    cat "$lock_file"
    exit 1
}

acquire_lock() {
    local lock_file="${TARGET_DIR:-.}/.asi-exec.lock"
    local task_id="${TASK_ID:-unknown}"
    
    if [[ -f "$lock_file" ]]; then
        # Check if stale first
        local stale_threshold=3600
        local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || stat -f %m "$lock_file")))
        
        if [[ $lock_age -le $stale_threshold ]]; then
            echo "Cannot acquire lock - execution in progress"
            exit 1
        fi
        echo "Removing stale lock"
    fi
    
    cat > "$lock_file" <<EOF
timestamp: $(date -Iseconds)
task_id: $task_id
pid: $$
EOF
    
    echo "Lock acquired for task: $task_id"
    exit 0
}

release_lock() {
    local lock_file="${TARGET_DIR:-.}/.asi-exec.lock"
    
    if [[ ! -f "$lock_file" ]]; then
        echo "No lock to release"
        exit 0
    fi
    
    rm -f "$lock_file"
    echo "Lock released"
    exit 0
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            plan-approved) check_plan_approved ;;
            plan-drift) check_plan_drift ;;
            todo) check_todo ;;
            task-pending) check_task_pending ;;
            deps-satisfied) check_deps_satisfied ;;
            lock-check) check_lock ;;
            lock-acquire) acquire_lock ;;
            lock-release) release_lock ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
