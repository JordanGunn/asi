#!/usr/bin/env bash
set -euo pipefail

# asi-kickoff validation script
# Read-only deterministic checks for kickoff artifacts

ASI_DIR=".asi/kickoff"
KICKOFF_FILE="$ASI_DIR/KICKOFF.md"
QUESTIONS_FILE="$ASI_DIR/QUESTIONS.md"
SKILL_TYPE_FILE="$ASI_DIR/SKILL_TYPE.json"
SCAFFOLD_FILE="$ASI_DIR/SCAFFOLD.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  dir-exists        .asi/kickoff/ directory exists
  kickoff-exists    KICKOFF.md exists
  kickoff-status    KICKOFF.md frontmatter status field
  kickoff-sections  KICKOFF.md has required H2 sections
  kickoff-approved  KICKOFF.md status == approved
  questions-exists  QUESTIONS.md exists
  questions-resolved All questions marked [x]
  skill-type-exists SKILL_TYPE.json exists
  skill-type-valid  SKILL_TYPE.json has required fields
  scaffold-exists   SCAFFOLD.json exists
  scaffold-valid    SCAFFOLD.json has required fields
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

check_dir_exists() {
    if [[ -d "$ASI_DIR" ]]; then
        echo "PASS: $ASI_DIR exists"
        return 0
    else
        echo "FAIL: $ASI_DIR does not exist"
        return 1
    fi
}

check_kickoff_exists() {
    if [[ -f "$KICKOFF_FILE" ]]; then
        echo "PASS: $KICKOFF_FILE exists"
        return 0
    else
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
}

check_kickoff_status() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$KICKOFF_FILE" "status")
    if [[ -n "$status" ]]; then
        echo "PASS: status=$status"
        return 0
    else
        echo "FAIL: status field missing"
        return 1
    fi
}

check_kickoff_sections() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
    local missing=0
    for section in "Purpose" "Deterministic Surface" "Judgment Remainder" "Schema Designs"; do
        if ! grep -q "^## $section" "$KICKOFF_FILE"; then
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

check_kickoff_approved() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi
    local status
    status=$(get_frontmatter_field "$KICKOFF_FILE" "status")
    if [[ "$status" == "approved" ]]; then
        echo "PASS: status=approved"
        return 0
    else
        echo "FAIL: status=$status (expected: approved)"
        return 1
    fi
}

check_questions_exists() {
    if [[ -f "$QUESTIONS_FILE" ]]; then
        echo "PASS: $QUESTIONS_FILE exists"
        return 0
    else
        echo "FAIL: $QUESTIONS_FILE does not exist"
        return 1
    fi
}

check_questions_resolved() {
    if [[ ! -f "$QUESTIONS_FILE" ]]; then
        echo "FAIL: $QUESTIONS_FILE does not exist"
        return 1
    fi
    local unresolved
    unresolved=$(grep -c '^\- \[ \]' "$QUESTIONS_FILE" 2>/dev/null) || unresolved=0
    if [[ "$unresolved" -eq 0 ]]; then
        echo "PASS: All questions resolved"
        return 0
    else
        echo "FAIL: $unresolved unresolved questions"
        return 1
    fi
}

check_skill_type_exists() {
    if [[ -f "$SKILL_TYPE_FILE" ]]; then
        echo "PASS: $SKILL_TYPE_FILE exists"
        return 0
    else
        echo "FAIL: $SKILL_TYPE_FILE does not exist"
        return 1
    fi
}

check_skill_type_valid() {
    if [[ ! -f "$SKILL_TYPE_FILE" ]]; then
        echo "FAIL: $SKILL_TYPE_FILE does not exist"
        return 1
    fi
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, skipping JSON validation" >&2
        echo "INFO: Run scripts/bootstrap.sh --check for install guidance." >&2
        return 0
    fi
    local type_field
    type_field=$(jq -r '.type // empty' "$SKILL_TYPE_FILE" 2>/dev/null)
    if [[ "$type_field" == "single" || "$type_field" == "grouped" ]]; then
        echo "PASS: type=$type_field"
        return 0
    else
        echo "FAIL: Invalid or missing type field"
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

check_scaffold_valid() {
    if [[ ! -f "$SCAFFOLD_FILE" ]]; then
        echo "FAIL: $SCAFFOLD_FILE does not exist"
        return 1
    fi
    if ! command -v jq &>/dev/null; then
        echo "WARN: jq not available, skipping JSON validation" >&2
        echo "INFO: Run scripts/bootstrap.sh --check for install guidance." >&2
        return 0
    fi
    if jq empty "$SCAFFOLD_FILE" 2>/dev/null; then
        echo "PASS: Valid JSON"
        return 0
    else
        echo "FAIL: Invalid JSON"
        return 1
    fi
}

check_all() {
    local failed=0
    echo "=== asi-kickoff validation ==="
    check_dir_exists || failed=1
    check_kickoff_exists || failed=1
    check_kickoff_status || failed=1
    check_kickoff_sections || failed=1
    check_questions_exists || failed=1
    check_skill_type_exists || failed=1
    check_skill_type_valid || failed=1
    check_scaffold_exists || failed=1
    check_scaffold_valid || failed=1
    echo "==="
    return $failed
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            dir-exists) check_dir_exists ;;
            kickoff-exists) check_kickoff_exists ;;
            kickoff-status) check_kickoff_status ;;
            kickoff-sections) check_kickoff_sections ;;
            kickoff-approved) check_kickoff_approved ;;
            questions-exists) check_questions_exists ;;
            questions-resolved) check_questions_resolved ;;
            skill-type-exists) check_skill_type_exists ;;
            skill-type-valid) check_skill_type_valid ;;
            scaffold-exists) check_scaffold_exists ;;
            scaffold-valid) check_scaffold_valid ;;
            all) check_all ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
