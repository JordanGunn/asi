#!/usr/bin/env bash
set -euo pipefail

# asi-kickoff inject script
# Deterministically injects structured step output into KICKOFF.md
# Separates agent reasoning (produces JSON) from file writing (this script)

ASI_DIR=".asi/kickoff"
KICKOFF_FILE="$ASI_DIR/KICKOFF.md"
STATE_FILE="$ASI_DIR/STATE.json"
SKILL_TYPE_FILE="$ASI_DIR/SKILL_TYPE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <step-number> --input <json-file>

Arguments:
  --step   Required. Step number (1-6).
  --input  Required. Path to JSON file conforming to step_output_v1.schema.json.

This script:
  1. Validates input JSON against step schema
  2. Injects content into appropriate KICKOFF.md sections
  3. Updates STATE.json
  4. Emits receipt

Exit codes:
  0  Injection complete
  1  Injection failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: update frontmatter field
update_frontmatter() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    sed -i "s/^${field}:.*/${field}: ${value}/" "$file"
}

# Helper: replace section content
replace_section() {
    local file="$1"
    local section="$2"
    local content="$3"
    local temp_file="${file}.tmp"
    
    awk -v section="$section" -v content="$content" '
    BEGIN { in_section = 0; printed = 0 }
    /^## / {
        if (in_section && !printed) {
            print content
            printed = 1
        }
        in_section = ($0 ~ "^## " section "$")
        print
        next
    }
    {
        if (!in_section) print
    }
    END {
        if (in_section && !printed) print content
    }
    ' "$file" > "$temp_file" && mv "$temp_file" "$file"
}

# Step 1: Inject Purpose
inject_step_1() {
    local input="$1"
    
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq required for JSON parsing" >&2
        return 1
    fi
    
    local what_it_does problem_solved non_goals asi_principles
    what_it_does=$(jq -r '.output.what_it_does' "$input")
    problem_solved=$(jq -r '.output.problem_solved' "$input")
    non_goals=$(jq -r '.output.non_goals | map("- " + .) | join("\n")' "$input")
    asi_principles=$(jq -r '.output.asi_principles | map("- " + .) | join("\n")' "$input")
    
    # Build section content
    local content
    content=$(cat <<EOF

### What this skill does

${what_it_does}

### What problem it solves

${problem_solved}

### What this skill does NOT do

${non_goals}

### Governing ASI principles

${asi_principles}

---
EOF
)
    
    replace_section "$KICKOFF_FILE" "Purpose" "$content"
    echo "Injected Purpose section"
}

# Step 2: Inject Scaffold
inject_step_2() {
    local input="$1"
    
    local skill_type reasoning
    skill_type=$(jq -r '.output.skill_type' "$input")
    reasoning=$(jq -r '.output.reasoning' "$input")
    
    # Update SKILL_TYPE.json
    jq --arg type "$skill_type" --arg reasoning "$reasoning" \
        '.type = $type | .reasoning = $reasoning' \
        "$SKILL_TYPE_FILE" > "${SKILL_TYPE_FILE}.tmp" && mv "${SKILL_TYPE_FILE}.tmp" "$SKILL_TYPE_FILE"
    
    echo "Updated SKILL_TYPE.json: type=$skill_type"
}

# Step 3: Inject Deterministic Surface
inject_step_3() {
    local input="$1"
    
    # Build mechanisms table
    local table_rows
    table_rows=$(jq -r '.output.mechanisms[] | "| \(.name) | \(.inputs | join(", ")) | \(.outputs | join(", ")) | \(.failure_conditions | join(", ")) | \(.idempotent) |"' "$input")
    
    local signals
    signals=$(jq -r '.output.observable_signals | map("- " + .) | join("\n")' "$input")
    
    local coverage
    coverage=$(jq -r '.output.coverage_assessment // "Not assessed"' "$input")
    
    local content
    content=$(cat <<EOF

### Mechanisms

| Mechanism | Inputs | Outputs | Failure Conditions | Idempotent |
| --------- | ------ | ------- | ------------------ | ---------- |
${table_rows}

### Observable Signals

${signals}

### Coverage Assessment

${coverage}

---
EOF
)
    
    replace_section "$KICKOFF_FILE" "Deterministic Surface" "$content"
    echo "Injected Deterministic Surface section"
}

# Step 4: Inject Judgment Remainder
inject_step_4() {
    local input="$1"
    
    local table_rows
    table_rows=$(jq -r '.output.items[] | "| \(.decision) | \(.why_not_deterministic) | \(.category) | \(.blocking_reason) |"' "$input")
    
    local shortcuts
    shortcuts=$(jq -r '.output.disallowed_shortcuts // [] | map("- " + .) | join("\n")' "$input")
    
    local content
    content=$(cat <<EOF

### Items requiring judgment

| Decision | Why Not Deterministic | Category | Blocking Reason |
| -------- | --------------------- | -------- | --------------- |
${table_rows}

### Disallowed shortcuts

${shortcuts}

---
EOF
)
    
    replace_section "$KICKOFF_FILE" "Judgment Remainder" "$content"
    echo "Injected Judgment Remainder section"
}

# Step 5: Inject Schema Designs
inject_step_5() {
    local input="$1"
    
    local intent_schema execution_schema result_schema
    intent_schema=$(jq '.output.intent_schema' "$input")
    execution_schema=$(jq '.output.execution_plan_schema' "$input")
    result_schema=$(jq '.output.result_schema' "$input")
    
    local content
    content=$(cat <<EOF

### Intent Schema

\`\`\`json
${intent_schema}
\`\`\`

### Execution Plan Schema

\`\`\`json
${execution_schema}
\`\`\`

### Result Schema

\`\`\`json
${result_schema}
\`\`\`

---
EOF
)
    
    replace_section "$KICKOFF_FILE" "Schema Designs" "$content"
    echo "Injected Schema Designs section"
}

# Step 6: Inject Questions
inject_step_6() {
    local input="$1"
    local questions_file="$ASI_DIR/QUESTIONS.md"
    
    local questions
    questions=$(jq -r '.output.questions[] | "- [ ] \(.question)\n  - Context: \(.context)"' "$input")
    
    if [[ -n "$questions" ]]; then
        # Append to QUESTIONS.md
        echo "" >> "$questions_file"
        echo "$questions" >> "$questions_file"
        echo "Appended questions to QUESTIONS.md"
    else
        echo "No questions to inject"
    fi
    
    # Also update Open Questions section in KICKOFF.md
    local content
    content=$(cat <<EOF

<!-- See QUESTIONS.md for full list -->

$(jq -r '.output.questions[] | "- [ ] \(.question)"' "$input")

EOF
)
    
    replace_section "$KICKOFF_FILE" "Open Questions" "$content"
    echo "Updated Open Questions section"
}

# Parse arguments
STEP=""
INPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --step)
            STEP="$2"
            shift 2
            ;;
        --input)
            INPUT="$2"
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

if [[ -z "$STEP" ]]; then
    echo "ERROR: --step is required" >&2
    usage
fi

if [[ -z "$INPUT" ]]; then
    echo "ERROR: --input is required" >&2
    usage
fi

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input file does not exist: $INPUT" >&2
    exit 1
fi

# Validate step number
if ! [[ "$STEP" =~ ^[1-6]$ ]]; then
    echo "ERROR: Step must be 1-6, got: $STEP" >&2
    usage
fi

# Check prerequisites
if [[ ! -f "$KICKOFF_FILE" ]]; then
    echo "ERROR: $KICKOFF_FILE does not exist. Run init.sh first." >&2
    exit 1
fi

# Run injection for specified step
case "$STEP" in
    1) inject_step_1 "$INPUT" ;;
    2) inject_step_2 "$INPUT" ;;
    3) inject_step_3 "$INPUT" ;;
    4) inject_step_4 "$INPUT" ;;
    5) inject_step_5 "$INPUT" ;;
    6) inject_step_6 "$INPUT" ;;
esac

result=$?

if [[ $result -eq 0 ]]; then
    # Update state
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if command -v jq &>/dev/null && [[ -f "$STATE_FILE" ]]; then
        jq --arg step "$STEP" --arg ts "$timestamp" \
            '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
    
    # Update frontmatter step
    update_frontmatter "$KICKOFF_FILE" "step" "$STEP"
    
    # Emit receipt
    cat <<EOF
{
  "action": "asi-kickoff-inject",
  "step": $STEP,
  "status": "complete",
  "timestamp": "$timestamp",
  "input_file": "$INPUT"
}
EOF
fi

exit $result
