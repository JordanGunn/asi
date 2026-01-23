#!/usr/bin/env bash
set -euo pipefail

# asi-plan checkpoint script
# Validates completion of each procedure step before allowing progression
# Gates agent work with deterministic checks

PLAN_DIR=".asi/plan"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
TASKS_FILE="$PLAN_DIR/tasks_scaffold.json"
STATE_FILE="$PLAN_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <step-number> [--advance]

Arguments:
  --step     Required. Step number to validate (1-8).
  --advance  Optional. If validation passes, advance state to next step.

Steps:
  1  generate_scaffold_tasks  Validate tasks_scaffold.json exists
  2  plan_scripts             Validate Scripts section filled
  3  plan_assets              Validate Assets section filled
  4  plan_validation          Validate Validation section filled
  5  plan_boundaries          Validate Boundaries section filled
  6  plan_risks               Validate Risks section filled
  7  plan_lifecycle           Validate Lifecycle section filled
  8  finalize_todo            Validate TODO.md tasks table filled

Exit codes:
  0  Validation passed
  1  Validation failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: check if section has content
section_has_content() {
    local file="$1"
    local section="$2"
    local content
    
    content=$(sed -n "/^## ${section}$/,/^## /p" "$file" | head -n -1 | tail -n +2)
    
    if echo "$content" | grep -qvE '^\s*$|^<!--|^-->|^\| *\|' 2>/dev/null; then
        return 0
    fi
    return 1
}

# Helper: check if table has data rows
table_has_data() {
    local file="$1"
    local section="$2"
    local table_content
    
    table_content=$(sed -n "/^## ${section}$/,/^## /p" "$file" | grep '|' | tail -n +3)
    
    if echo "$table_content" | grep -qE '\|[^|]+[^ |]+' 2>/dev/null; then
        return 0
    fi
    return 1
}

# Helper: update state file
update_state() {
    local step="$1"
    local status="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, cannot update state file"
        return 0
    fi
    
    jq --arg step "$step" --arg status "$status" --arg ts "$timestamp" \
        '.steps[$step].status = $status | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
}

# Step 1: Validate scaffold tasks generated
validate_step_1() {
    echo "=== Validating Step 1: Generate Scaffold Tasks ==="
    
    if [[ -f "$TASKS_FILE" ]]; then
        if command -v jq &>/dev/null; then
            local count
            count=$(jq -r '.task_count // 0' "$TASKS_FILE")
            echo "PASS: $TASKS_FILE exists with $count tasks"
        else
            echo "PASS: $TASKS_FILE exists"
        fi
        return 0
    else
        echo "FAIL: $TASKS_FILE does not exist. Run scripts/generate-tasks.sh"
        return 1
    fi
}

# Step 2: Validate Scripts section
validate_step_2() {
    echo "=== Validating Step 2: Scripts Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Scripts"; then
        echo "FAIL: Scripts section has no content"
        failed=1
    else
        echo "PASS: Scripts section has content"
    fi
    
    if ! table_has_data "$PLAN_FILE" "Scripts"; then
        echo "WARN: Scripts table appears empty"
    else
        echo "PASS: Scripts table has data"
    fi
    
    return $failed
}

# Step 3: Validate Assets section
validate_step_3() {
    echo "=== Validating Step 3: Assets Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Assets"; then
        echo "FAIL: Assets section has no content"
        failed=1
    else
        echo "PASS: Assets section has content"
    fi
    
    return $failed
}

# Step 4: Validate Validation section
validate_step_4() {
    echo "=== Validating Step 4: Validation Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Validation"; then
        echo "FAIL: Validation section has no content"
        failed=1
    else
        echo "PASS: Validation section has content"
    fi
    
    return $failed
}

# Step 5: Validate Boundaries section
validate_step_5() {
    echo "=== Validating Step 5: Boundaries Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Boundaries"; then
        echo "FAIL: Boundaries section has no content"
        failed=1
    else
        echo "PASS: Boundaries section has content"
    fi
    
    return $failed
}

# Step 6: Validate Risks section
validate_step_6() {
    echo "=== Validating Step 6: Risks Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Risks"; then
        echo "FAIL: Risks section has no content"
        failed=1
    else
        echo "PASS: Risks section has content"
    fi
    
    return $failed
}

# Step 7: Validate Lifecycle section
validate_step_7() {
    echo "=== Validating Step 7: Lifecycle Section ==="
    local failed=0
    
    if ! section_has_content "$PLAN_FILE" "Lifecycle"; then
        echo "FAIL: Lifecycle section has no content"
        failed=1
    else
        echo "PASS: Lifecycle section has content"
    fi
    
    return $failed
}

# Step 8: Validate TODO finalized
validate_step_8() {
    echo "=== Validating Step 8: Finalize TODO ==="
    local failed=0
    
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "FAIL: $TODO_FILE does not exist"
        return 1
    fi
    
    # Check for tasks in table
    local task_count
    task_count=$(grep -c '^\| T[0-9]' "$TODO_FILE" 2>/dev/null || echo "0")
    
    if [[ "$task_count" -gt 0 ]]; then
        echo "PASS: TODO.md has $task_count tasks"
    else
        echo "FAIL: TODO.md has no tasks"
        failed=1
    fi
    
    # Check traceability
    local missing_trace=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*T[0-9]+ ]]; then
            local source_section
            source_section=$(echo "$line" | awk -F'|' '{print $(NF-1)}' | xargs)
            if [[ -z "$source_section" ]]; then
                ((missing_trace++))
            fi
        fi
    done < "$TODO_FILE"
    
    if [[ $missing_trace -gt 0 ]]; then
        echo "WARN: $missing_trace tasks missing source reference"
    else
        echo "PASS: All tasks have source reference"
    fi
    
    return $failed
}

# Parse arguments
STEP=""
ADVANCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --step)
            STEP="$2"
            shift 2
            ;;
        --advance)
            ADVANCE=true
            shift
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

if [[ -z "$STEP" ]]; then
    echo "ERROR: --step is required" >&2
    usage
fi

if ! [[ "$STEP" =~ ^[1-8]$ ]]; then
    echo "ERROR: Step must be 1-8, got: $STEP" >&2
    usage
fi

# Check prerequisites
if [[ ! -d "$PLAN_DIR" ]]; then
    echo "ERROR: $PLAN_DIR does not exist. Run init.sh first." >&2
    exit 1
fi

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "ERROR: $PLAN_FILE does not exist. Run init.sh first." >&2
    exit 1
fi

# Run validation for specified step
case "$STEP" in
    1) validate_step_1 ;;
    2) validate_step_2 ;;
    3) validate_step_3 ;;
    4) validate_step_4 ;;
    5) validate_step_5 ;;
    6) validate_step_6 ;;
    7) validate_step_7 ;;
    8) validate_step_8 ;;
esac

result=$?

if [[ $result -eq 0 ]]; then
    echo "=== Step $STEP: PASSED ==="
    
    if [[ "$ADVANCE" == true ]]; then
        update_state "$STEP" "complete"
        next_step=$((STEP + 1))
        if [[ $next_step -le 8 ]]; then
            echo "Advanced to step $next_step"
        else
            echo "All steps complete. Ready for review."
        fi
    fi
else
    echo "=== Step $STEP: FAILED ==="
    echo "Fix the issues above before proceeding."
fi

exit $result
