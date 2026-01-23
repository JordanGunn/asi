#!/usr/bin/env bash
set -euo pipefail

# plan skill - validate.sh
# Validates plan structure and schema

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  prereqs   Validate plan directory structure
  schema    Validate active.yaml schema
  steps     Validate step IDs and statuses
  all       Run all checks

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

check_prereqs() {
    local failed=0
    echo "=== Checking prerequisites ==="
    
    if [[ -d "$PLAN_DIR" ]]; then
        echo "PASS: $PLAN_DIR exists"
    else
        echo "FAIL: $PLAN_DIR does not exist"
        failed=1
    fi
    
    if [[ -f "$ACTIVE_FILE" ]]; then
        echo "PASS: $ACTIVE_FILE exists"
    else
        echo "INFO: No active plan"
    fi
    
    return $failed
}

check_schema() {
    local failed=0
    echo "=== Checking schema ==="
    
    if [[ ! -f "$ACTIVE_FILE" ]]; then
        echo "SKIP: No active plan"
        return 0
    fi
    
    # Check required fields
    if grep -q "^name:" "$ACTIVE_FILE"; then
        echo "PASS: name field present"
    else
        echo "FAIL: name field missing"
        failed=1
    fi
    
    if grep -q "^created_at:" "$ACTIVE_FILE"; then
        echo "PASS: created_at field present"
    else
        echo "FAIL: created_at field missing"
        failed=1
    fi
    
    if grep -q "^status:" "$ACTIVE_FILE"; then
        echo "PASS: status field present"
    else
        echo "FAIL: status field missing"
        failed=1
    fi
    
    if grep -q "^steps:" "$ACTIVE_FILE"; then
        echo "PASS: steps field present"
    else
        echo "FAIL: steps field missing"
        failed=1
    fi
    
    return $failed
}

check_steps() {
    local failed=0
    echo "=== Checking steps ==="
    
    if [[ ! -f "$ACTIVE_FILE" ]]; then
        echo "SKIP: No active plan"
        return 0
    fi
    
    # Check for duplicate IDs
    local ids
    ids=$(grep -E "id:[[:space:]]*\"?S[0-9]+\"?" "$ACTIVE_FILE" | sed -E 's/.*id:[[:space:]]*\"?([^\"]+)\"?.*/\1/' | sort)
    local unique_ids
    unique_ids=$(echo "$ids" | uniq)
    
    if [[ "$ids" == "$unique_ids" ]]; then
        echo "PASS: No duplicate step IDs"
    else
        echo "FAIL: Duplicate step IDs found"
        failed=1
    fi
    
    # Check ID format
    local invalid_ids
    invalid_ids=$(echo "$ids" | grep -vE "^S[0-9]{3}$" || true)
    if [[ -z "$invalid_ids" ]]; then
        echo "PASS: All step IDs have valid format (S###)"
    else
        echo "WARN: Some step IDs don't match S### format"
    fi
    
    # Check status values
    local invalid_status
    invalid_status=$(grep -E "status:[[:space:]]" "$ACTIVE_FILE" | grep -vE "status:[[:space:]]*(pending|in_progress|done|skipped|active|completed|archived)" || true)
    if [[ -z "$invalid_status" ]]; then
        echo "PASS: All status values are valid"
    else
        echo "FAIL: Invalid status values found"
        failed=1
    fi
    
    # Count steps
    local step_count
    step_count=$(grep -c "id: \"S" "$ACTIVE_FILE" 2>/dev/null || echo "0")
    echo "INFO: $step_count steps in plan"
    
    return $failed
}

check_all() {
    local failed=0
    check_prereqs || failed=1
    check_schema || failed=1
    check_steps || failed=1
    
    echo "==="
    if [[ $failed -eq 0 ]]; then
        echo "All checks passed"
    else
        echo "Some checks failed"
    fi
    
    return $failed
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            prereqs) check_prereqs ;;
            schema) check_schema ;;
            steps) check_steps ;;
            all) check_all ;;
            *) echo "Unknown check: $2" >&2; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
