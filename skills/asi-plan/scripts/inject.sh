#!/usr/bin/env bash
set -euo pipefail

# asi-plan inject script
# Deterministically injects structured step output into PLAN.md and TODO.md
# Separates agent reasoning (produces JSON) from file writing (this script)

PLAN_DIR=".asi/plan"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
STATE_FILE="$PLAN_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <step-number> --input <json-file>

Arguments:
  --step   Required. Step number (2-8). Step 1 uses generate-tasks.sh.
  --input  Required. Path to JSON file conforming to step schema.

This script:
  1. Validates input JSON
  2. Injects content into appropriate PLAN.md/TODO.md sections
  3. Updates STATE.json
  4. Emits receipt

Exit codes:
  0  Injection complete
  1  Injection failed
  2  Invalid arguments
EOF
    exit 2
}

# Helper: portable in-place sed (GNU + BSD/macOS)
sed_inplace() {
    local expr file
    expr="$1"
    file="$2"

    if sed --version >/dev/null 2>&1; then
        sed -i "$expr" "$file"
    else
        sed -i '' "$expr" "$file"
    fi
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

# Helper: update frontmatter field
update_frontmatter() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    sed_inplace "s/^${field}:.*/${field}: ${value}/" "$file"
}

# Helper: replace section content
replace_section() {
    local file="$1"
    local section="$2"
    local content="$3"
    local temp_file="${file}.tmp"
    local content_file
    content_file="$(mktemp)"

    # Preserve all newlines exactly (avoid awk -v multiline portability issues)
    printf '%s' "$content" > "$content_file"
    
    awk -v section="## " -v name="$section" -v content_file="$content_file" '
    function print_content(   line) {
        while ((getline line < content_file) > 0) print line
        close(content_file)
    }
    BEGIN { in_section = 0 }
    /^## / {
        if (in_section) {
            print_content()
            in_section = 0
        }
        if ($0 == section name) {
            print
            in_section = 1
            next
        }
        print
        next
    }
    {
        if (!in_section) print
    }
    END {
        if (in_section) print_content()
    }
    ' "$file" > "$temp_file" && mv "$temp_file" "$file"

    rm -f "$content_file"
}

# Step 2: Inject Scripts section
inject_step_2() {
    local input="$1"
    
    local table_rows
    table_rows=$(jq -r '.output.scripts[] | "| \(.name) | \(.purpose) | \(.inputs // "-") | \(.outputs // "-") |"' "$input" 2>/dev/null || echo "")
    
    if [[ -z "$table_rows" ]]; then
        echo "WARN: No scripts in input"
        table_rows="| (none) | - | - | - |"
    fi
    
    local content
    content=$(cat <<EOF

| Script | Purpose | Inputs | Outputs |
| ------ | ------- | ------ | ------- |
${table_rows}

---
EOF
)
    
    replace_section "$PLAN_FILE" "Scripts" "$content"
    echo "Injected Scripts section"
}

# Step 3: Inject Assets section
inject_step_3() {
    local input="$1"
    
    local schema_rows
    schema_rows=$(jq -r '.output.schemas[] | "| \(.name) | \(.purpose) |"' "$input" 2>/dev/null || echo "")
    
    local template_rows
    template_rows=$(jq -r '.output.templates[] | "| \(.name) | \(.purpose) |"' "$input" 2>/dev/null || echo "")
    
    local content
    content=$(cat <<EOF

### Schemas

| Schema | Purpose |
| ------ | ------- |
${schema_rows:-| (none) | - |}

### Templates

| Template | Purpose |
| -------- | ------- |
${template_rows:-| (none) | - |}

---
EOF
)
    
    replace_section "$PLAN_FILE" "Assets" "$content"
    echo "Injected Assets section"
}

# Step 4: Inject Validation section
inject_step_4() {
    local input="$1"
    
    local table_rows
    table_rows=$(jq -r '.output.validations[] | "| \(.mechanism) | \(.validates) | \(.failure_behavior) |"' "$input" 2>/dev/null || echo "")
    
    local content
    content=$(cat <<EOF

| Mechanism | What it validates | Failure behavior |
| --------- | ----------------- | ---------------- |
${table_rows:-| (none) | - | - |}

---
EOF
)
    
    replace_section "$PLAN_FILE" "Validation" "$content"
    echo "Injected Validation section"
}

# Step 5: Inject Boundaries section
inject_step_5() {
    local input="$1"
    
    local in_scope
    in_scope=$(jq -r '.output.in_scope | map("- " + .) | join("\n")' "$input" 2>/dev/null || echo "- (not specified)")
    
    local out_of_scope
    out_of_scope=$(jq -r '.output.out_of_scope | map("- " + .) | join("\n")' "$input" 2>/dev/null || echo "- (not specified)")
    
    local content
    content=$(cat <<EOF

### In scope

${in_scope}

### Out of scope

${out_of_scope}

---
EOF
)
    
    replace_section "$PLAN_FILE" "Boundaries" "$content"
    echo "Injected Boundaries section"
}

# Step 6: Inject Risks section
inject_step_6() {
    local input="$1"
    
    local table_rows
    table_rows=$(jq -r '.output.risks[] | "| \(.risk) | \(.severity) | \(.mitigation) |"' "$input" 2>/dev/null || echo "")
    
    local content
    content=$(cat <<EOF

| Risk | Severity | Mitigation |
| ---- | -------- | ---------- |
${table_rows:-| (none identified) | - | - |}

---
EOF
)
    
    replace_section "$PLAN_FILE" "Risks" "$content"
    echo "Injected Risks section"
}

# Step 7: Inject Lifecycle section
inject_step_7() {
    local input="$1"
    
    local artifacts
    artifacts=$(jq -r '.output.artifacts | map("- " + .) | join("\n")' "$input" 2>/dev/null || echo "- (not specified)")
    
    local status_flow
    status_flow=$(jq -r '.output.status_flow // "draft → review → approved"' "$input" 2>/dev/null)
    
    local human_gates
    human_gates=$(jq -r '.output.human_gates | map("- " + .) | join("\n")' "$input" 2>/dev/null || echo "- (not specified)")
    
    local content
    content=$(cat <<EOF

### Artifacts produced

${artifacts}

### Status flow

${status_flow}

### Human gates

${human_gates}

EOF
)
    
    replace_section "$PLAN_FILE" "Lifecycle" "$content"
    echo "Injected Lifecycle section"
}

# Step 8: Inject TODO tasks
inject_step_8() {
    local input="$1"
    
    # Build task table from input
    local table_rows
    table_rows=$(jq -r '.output.tasks[] | "| \(.id) | \(.description) | \(.status // "pending") | \(.depends_on // "-") | \(.source_section) |"' "$input" 2>/dev/null || echo "")
    
    if [[ -z "$table_rows" ]]; then
        echo "ERROR: No tasks in input"
        return 1
    fi
    
    local content
    content=$(cat <<EOF

| ID   | Description | Status  | Depends On | Source Section |
| ---- | ----------- | ------- | ---------- | -------------- |
${table_rows}

---
EOF
)
    
    replace_section "$TODO_FILE" "Tasks" "$content"
    
    # Update TODO hash of PLAN
    local plan_hash
    plan_hash=$(sha256_file "$PLAN_FILE")
    update_frontmatter "$TODO_FILE" "source_plan_hash" "$plan_hash"
    
    echo "Injected Tasks into TODO.md"
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

if ! [[ "$STEP" =~ ^[2-8]$ ]]; then
    echo "ERROR: Step must be 2-8 for inject (step 1 uses generate-tasks.sh), got: $STEP" >&2
    usage
fi

# Check prerequisites
if [[ ! -f "$PLAN_FILE" ]]; then
    echo "ERROR: $PLAN_FILE does not exist. Run init.sh first." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required for injection. Run scripts/bootstrap.sh --check for install guidance." >&2
    exit 1
fi

# Run injection for specified step
case "$STEP" in
    2) inject_step_2 "$INPUT" ;;
    3) inject_step_3 "$INPUT" ;;
    4) inject_step_4 "$INPUT" ;;
    5) inject_step_5 "$INPUT" ;;
    6) inject_step_6 "$INPUT" ;;
    7) inject_step_7 "$INPUT" ;;
    8) inject_step_8 "$INPUT" ;;
esac

result=$?

if [[ $result -eq 0 ]]; then
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update state
    if [[ -f "$STATE_FILE" ]]; then
        jq --arg step "$STEP" --arg ts "$timestamp" \
            '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
    
    # Update frontmatter step
    update_frontmatter "$PLAN_FILE" "step" "$STEP"
    
    # Emit receipt
    cat <<EOF
{
  "action": "asi-plan-inject",
  "step": $STEP,
  "status": "complete",
  "timestamp": "$timestamp",
  "input_file": "$INPUT"
}
EOF
fi

exit $result
