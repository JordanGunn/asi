#!/usr/bin/env bash
set -euo pipefail

# asi-plan validation script
# Read-only deterministic checks for plan artifacts

 TARGET_DIR="${TARGET_DIR:-}"
 if [[ -z "${TARGET_DIR}" ]]; then
     if TARGET_DIR=$(git rev-parse --show-toplevel 2>/dev/null); then
         :
     else
         TARGET_DIR="."
     fi
 fi
 cd "$TARGET_DIR"

KICKOFF_DIR=".asi/kickoff"
PLAN_DIR=".asi/plan"
KICKOFF_FILE="$KICKOFF_DIR/KICKOFF.md"
SKILL_TYPE_FILE="$KICKOFF_DIR/SKILL_TYPE.json"
SCAFFOLD_FILE="$KICKOFF_DIR/SCAFFOLD.json"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  prereqs           All prerequisites for asi-plan
  kickoff-approved  KICKOFF.md status == approved
  kickoff-artifacts All kickoff artifacts exist and valid
  plan-exists       PLAN.md exists
  plan-status       PLAN.md frontmatter status field
  plan-sections     PLAN.md has required H2 sections
  plan-approved     PLAN.md status == approved
  todo-exists       TODO.md exists
  todo-status       TODO.md frontmatter status field
  todo-tasks        TODO.md has task table
  todo-complete     All tasks status == done
  kickoff-drift     KICKOFF.md hash matches stored hash
  traceability      All TODO tasks have source reference
  all               Run all checks

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

# Helper: portable sha256 hash
sha256_file() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
        return 0
    fi
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
        return 0
    fi
    if command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$file" | awk '{print $NF}'
        return 0
    fi
    echo "ERROR: No sha256 tool found (need sha256sum, shasum, or openssl)" >&2
    return 1
}

check_prereqs() {
    local failed=0
    echo "=== asi-plan prerequisites ==="
    
    if [[ ! -d "$KICKOFF_DIR" ]]; then
        echo "FAIL: $KICKOFF_DIR does not exist"
        failed=1
    else
        echo "PASS: $KICKOFF_DIR exists"
    fi
    
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        failed=1
    else
        echo "PASS: $KICKOFF_FILE exists"
    fi
    
    if [[ ! -f "$SKILL_TYPE_FILE" ]]; then
        echo "FAIL: $SKILL_TYPE_FILE does not exist"
        failed=1
    else
        echo "PASS: $SKILL_TYPE_FILE exists"
    fi
    
    if [[ ! -f "$SCAFFOLD_FILE" ]]; then
        echo "FAIL: $SCAFFOLD_FILE does not exist"
        failed=1
    else
        echo "PASS: $SCAFFOLD_FILE exists"
    fi
    
    check_kickoff_approved || failed=1
    
    echo "==="
    return $failed
}

check_kickoff_approved() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$KICKOFF_FILE" "status")
    if [[ "$status" == "approved" ]]; then
        echo "PASS: KICKOFF.md status=approved"
        return 0
    else
        echo "FAIL: KICKOFF.md status=$status (expected: approved)"
        return 1
    fi
}

check_kickoff_artifacts() {
    local failed=0
    for f in "$KICKOFF_FILE" "$SKILL_TYPE_FILE" "$SCAFFOLD_FILE"; do
        if [[ -f "$f" ]]; then
            echo "PASS: $f exists"
        else
            echo "FAIL: $f does not exist"
            failed=1
        fi
    done
    return $failed
}

check_plan_exists() {
    if [[ -f "$PLAN_FILE" ]]; then
        echo "PASS: $PLAN_FILE exists"
        return 0
    else
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
}

check_plan_status() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$PLAN_FILE" "status")
    if [[ -n "$status" ]]; then
        echo "PASS: status=$status"
        return 0
    else
        echo "FAIL: status field missing"
        return 1
    fi
}

check_plan_sections() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
    local missing=0
    for section in "Scripts" "Assets" "Validation" "Boundaries" "Non-goals" "Risks" "Lifecycle"; do
        if ! grep -q "^## $section" "$PLAN_FILE"; then
            echo "FAIL: Missing section: $section"
            missing=1
        fi
    done
    if [[ "$missing" -eq 0 ]]; then
        echo "PASS: All required sections present"
        return 0
    fi
    return 1
}

check_plan_approved() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$PLAN_FILE" "status")
    if [[ "$status" == "approved" ]]; then
        echo "PASS: status=approved"
        return 0
    else
        echo "FAIL: status=$status (expected: approved)"
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

check_todo_status() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$TODO_FILE" "status")
    if [[ -n "$status" ]]; then
        echo "PASS: status=$status"
        return 0
    else
        echo "FAIL: status field missing"
        return 1
    fi
}

check_todo_tasks() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    local task_count
    task_count=$(grep -cE '^\|[[:space:]]*T[0-9]+' "$TODO_FILE" 2>/dev/null || echo "0")
    if [[ "$task_count" -gt 0 ]]; then
        echo "PASS: $task_count tasks found"
        return 0
    else
        echo "FAIL: No tasks found"
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

check_kickoff_drift() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        echo "FAIL: $PLAN_FILE does not exist"
        return 1
    fi
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
    local stored_hash
    stored_hash=$(get_frontmatter_field "$PLAN_FILE" "source_kickoff_hash")
    if [[ -z "$stored_hash" ]]; then
        echo "WARN: PLAN.md missing source_kickoff_hash field"
        return 0
    fi
    local current_hash
    current_hash=$(sha256_file "$KICKOFF_FILE")
    if [[ "$stored_hash" != "$current_hash" ]]; then
        echo "FAIL: KICKOFF.md has changed (drift detected)"
        return 1
    fi
    echo "PASS: No drift detected"
    return 0
}

check_traceability() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    local missing_trace=0
    local task_count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*ID || "$line" =~ ^\|[[:space:]]*-+ ]]; then
            continue
        fi
        if [[ "$line" =~ ^\|[[:space:]]*T[0-9]+ ]]; then
            ((task_count++))
            local source_section
            source_section=$(echo "$line" | awk -F'|' '{print $(NF-1)}' | xargs)
            if [[ -z "$source_section" ]]; then
                ((missing_trace++))
            fi
        fi
    done < "$TODO_FILE"
    if [[ $task_count -eq 0 ]]; then
        echo "FAIL: No tasks found"
        return 1
    fi
    if [[ $missing_trace -gt 0 ]]; then
        echo "FAIL: $missing_trace of $task_count tasks missing source reference"
        return 1
    fi
    echo "PASS: All $task_count tasks have source reference"
    return 0
}

check_all() {
    local failed=0
    echo "=== asi-plan validation ==="
    check_prereqs || failed=1
    check_plan_exists || failed=1
    check_plan_status || failed=1
    check_todo_exists || failed=1
    check_todo_status || failed=1
    check_todo_tasks || failed=1
    check_traceability || failed=1
    echo "==="
    return $failed
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            prereqs) check_prereqs ;;
            kickoff-approved) check_kickoff_approved ;;
            kickoff-artifacts) check_kickoff_artifacts ;;
            plan-exists) check_plan_exists ;;
            plan-status) check_plan_status ;;
            plan-sections) check_plan_sections ;;
            plan-approved) check_plan_approved ;;
            todo-exists) check_todo_exists ;;
            todo-status) check_todo_status ;;
            todo-tasks) check_todo_tasks ;;
            todo-complete) check_todo_complete ;;
            kickoff-drift) check_kickoff_drift ;;
            traceability) check_traceability ;;
            all) check_all ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
