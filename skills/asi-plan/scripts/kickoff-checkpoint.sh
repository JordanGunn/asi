#!/usr/bin/env bash
set -euo pipefail

# asi-plan kickoff-phase checkpoint script
# Validates completion of each procedure step before allowing progression
# Gates agent work with deterministic checks

ASI_DIR=".asi/kickoff"
KICKOFF_FILE="$ASI_DIR/KICKOFF.md"
QUESTIONS_FILE="$ASI_DIR/QUESTIONS.md"
SKILL_TYPE_FILE="$ASI_DIR/SKILL_TYPE.json"
SCAFFOLD_FILE="$ASI_DIR/SCAFFOLD.json"
STATE_FILE="$ASI_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <step-number> [--advance]

Arguments:
  --step     Required. Step number to validate (1-6).
  --advance  Optional. If validation passes, advance state to next step.

Steps:
  1  purpose              Validate Purpose section is filled
  2  scaffold             Validate SKILL_TYPE.json and scaffold decision
  3  deterministic_surface Validate Deterministic Surface section
  4  judgment_remainder   Validate Judgment Remainder section
  5  schemas              Validate Schema Designs section
  6  questions            Validate Open Questions captured

Exit codes:
  0  Validation passed
  1  Validation failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: extract markdown section body (lines after "## <section>" until next H2)
extract_section_body() {
    local file="$1"
    local section="$2"
    awk -v section="$section" '
    $0 == "## " section { in_section = 1; next }
    in_section && /^## / { exit }
    in_section { print }
    ' "$file"
}

# Helper: check if section has content (not just template comments)
section_has_content() {
    local file="$1"
    local section="$2"
    local content
    
    # Extract section content between this H2 and next H2 or end
    content=$(extract_section_body "$file" "$section")
    
    # Check if content exists beyond just HTML comments and empty table rows
    if echo "$content" | grep -qvE '^\s*$|^<!--|^-->|^\| *\|' 2>/dev/null; then
        return 0
    fi
    return 1
}

# Helper: check if table has data rows (not just header and empty row)
table_has_data() {
    local file="$1"
    local section="$2"
    local table_content
    
    # Extract table from section
    table_content=$(sed -n "/^## ${section}$/,/^## /p" "$file" | grep '|' | tail -n +3)
    
    # Check if any row has content beyond just pipes and spaces
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
        echo "WARN: jq not available, cannot update state file" >&2
        echo "INFO: Run scripts/kickoff-bootstrap.sh --check for install guidance." >&2
        return 0
    fi
    
    jq --arg step "$step" --arg status "$status" --arg ts "$timestamp" \
        '.steps[$step].status = $status | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
}

# Step 1: Validate Purpose section
validate_step_1() {
    echo "=== Validating Step 1: Purpose ==="
    local failed=0
    
    if ! section_has_content "$KICKOFF_FILE" "Purpose"; then
        echo "FAIL: Purpose section has no content"
        failed=1
    else
        echo "PASS: Purpose section has content"
    fi
    
    # Check subsections
    for subsection in "What this skill does" "What problem it solves" "What this skill does NOT do"; do
        if ! grep -q "^### ${subsection}$" "$KICKOFF_FILE"; then
            echo "FAIL: Missing subsection: $subsection"
            failed=1
        fi
    done
    
    return $failed
}

# Step 2: Validate Scaffold decision
validate_step_2() {
    echo "=== Validating Step 2: Scaffold ==="
    local failed=0
    
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, skipping JSON validation" >&2
        echo "INFO: Run scripts/kickoff-bootstrap.sh --check for install guidance." >&2
        return 0
    fi
    
    # Check SKILL_TYPE.json has type field set
    local skill_type
    skill_type=$(jq -r '.type // empty' "$SKILL_TYPE_FILE" 2>/dev/null)
    
    if [[ -z "$skill_type" || "$skill_type" == "null" ]]; then
        echo "FAIL: SKILL_TYPE.json type field not set"
        failed=1
    elif [[ "$skill_type" != "single" && "$skill_type" != "grouped" ]]; then
        echo "FAIL: SKILL_TYPE.json type must be 'single' or 'grouped', got: $skill_type"
        failed=1
    else
        echo "PASS: SKILL_TYPE.json type=$skill_type"
    fi
    
    # Check reasoning field is set
    local reasoning
    reasoning=$(jq -r '.reasoning // empty' "$SKILL_TYPE_FILE" 2>/dev/null)
    
    if [[ -z "$reasoning" || "$reasoning" == "null" ]]; then
        echo "FAIL: SKILL_TYPE.json reasoning field not set"
        failed=1
    else
        echo "PASS: SKILL_TYPE.json has reasoning"
    fi
    
    return $failed
}

# Step 3: Validate Deterministic Surface
validate_step_3() {
    echo "=== Validating Step 3: Deterministic Surface ==="
    local failed=0
    
    if ! section_has_content "$KICKOFF_FILE" "Deterministic Surface"; then
        echo "FAIL: Deterministic Surface section has no content"
        failed=1
    else
        echo "PASS: Deterministic Surface section has content"
    fi
    
    # Check mechanisms table has data
    if ! table_has_data "$KICKOFF_FILE" "Deterministic Surface"; then
        echo "WARN: Mechanisms table appears empty (may be intentional if no deterministic mechanisms)"
    else
        echo "PASS: Mechanisms table has data"
    fi
    
    return $failed
}

# Step 4: Validate Judgment Remainder
validate_step_4() {
    echo "=== Validating Step 4: Judgment Remainder ==="
    local failed=0
    
    if ! section_has_content "$KICKOFF_FILE" "Judgment Remainder"; then
        echo "FAIL: Judgment Remainder section has no content"
        failed=1
    else
        echo "PASS: Judgment Remainder section has content"
    fi
    
    return $failed
}

# Step 5: Validate Schema Designs
validate_step_5() {
    echo "=== Validating Step 5: Schema Designs ==="
    local failed=0
    
    # Check for JSON code blocks with actual content
    local schema_count
    schema_count=$(grep -c '```json' "$KICKOFF_FILE" 2>/dev/null) || schema_count=0
    
    if [[ "$schema_count" -lt 3 ]]; then
        echo "FAIL: Expected at least 3 schema definitions, found: $schema_count"
        failed=1
    else
        echo "PASS: Found $schema_count schema definitions"
    fi
    
    # Check schemas have content beyond template comment
    for schema in "Intent Schema" "Execution Plan Schema" "Result Schema"; do
        if ! grep -q "^### ${schema}$" "$KICKOFF_FILE"; then
            echo "FAIL: Missing schema section: $schema"
            failed=1
        fi
    done
    
    return $failed
}

# Step 6: Validate Questions
validate_step_6() {
    echo "=== Validating Step 6: Open Questions ==="
    local failed=0
    
    if [[ ! -f "$QUESTIONS_FILE" ]]; then
        echo "FAIL: QUESTIONS.md does not exist"
        return 1
    fi
    
    echo "PASS: QUESTIONS.md exists"
    
    # Questions may legitimately be empty if none arose
    local question_count
    question_count=$(grep -c '^\- \[' "$QUESTIONS_FILE" 2>/dev/null) || question_count=0
    echo "INFO: $question_count questions captured"
    
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

# Validate step number
if ! [[ "$STEP" =~ ^[1-6]$ ]]; then
    echo "ERROR: Step must be 1-6, got: $STEP" >&2
    usage
fi

# Check prerequisites
if [[ ! -d "$ASI_DIR" ]]; then
    echo "ERROR: $ASI_DIR does not exist. Run init.sh first." >&2
    exit 1
fi

if [[ ! -f "$KICKOFF_FILE" ]]; then
    echo "ERROR: $KICKOFF_FILE does not exist. Run init.sh first." >&2
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
esac

result=$?

if [[ $result -eq 0 ]]; then
    echo "=== Step $STEP: PASSED ==="
    
    if [[ "$ADVANCE" == true ]]; then
        update_state "$STEP" "complete"
        next_step=$((STEP + 1))
        if [[ $next_step -le 6 ]]; then
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
