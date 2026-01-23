#!/usr/bin/env bash
set -euo pipefail

# asi-exec initialization script
# Deterministic preamble: validates prerequisites, parses plan artifacts, creates structure
# Agent work happens AFTER this script completes

KICKOFF_DIR=".asi/kickoff"
PLAN_DIR=".asi/plan"
EXEC_DIR=".asi/exec"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
SCAFFOLD_FILE="$KICKOFF_DIR/SCAFFOLD.json"
PARSED_FILE="$EXEC_DIR/PLAN_PARSED.json"
STATE_FILE="$EXEC_DIR/STATE.json"
RECEIPT_FILE="$EXEC_DIR/RECEIPT.md"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--force]

Arguments:
  --force  Reinitialize even if exec directory exists.

This script:
  1. Validates prerequisites (PLAN.md approved, TODO.md exists)
  2. Parses plan artifacts into structured JSON
  3. Creates .asi/exec/ directory
  4. Parses TODO.md tasks into structured format
  5. Computes source_plan_hash for drift detection
  6. Creates STATE.json to track execution progress
  7. Emits receipt to stdout

Exit codes:
  0  Initialization complete
  1  Initialization failed (prerequisites not met)
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

# Parse arguments
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
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

# Validate prerequisites
echo "=== Validating prerequisites ===" >&2

if [[ ! -d "$PLAN_DIR" ]]; then
    echo "ERROR: $PLAN_DIR does not exist. Run asi-plan first." >&2
    exit 1
fi

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "ERROR: $PLAN_FILE does not exist. Run asi-plan first." >&2
    exit 1
fi

PLAN_STATUS=$(get_frontmatter_field "$PLAN_FILE" "status")
if [[ "$PLAN_STATUS" != "approved" ]]; then
    echo "ERROR: PLAN.md status is '$PLAN_STATUS', expected 'approved'." >&2
    echo "Approve the plan before running asi-exec." >&2
    exit 1
fi

if [[ ! -f "$TODO_FILE" ]]; then
    echo "ERROR: $TODO_FILE does not exist. Run asi-plan first." >&2
    exit 1
fi

if [[ ! -f "$SCAFFOLD_FILE" ]]; then
    echo "WARN: $SCAFFOLD_FILE does not exist. Scaffolding tasks may fail." >&2
fi

echo "Prerequisites validated." >&2

# Check if exec already exists
if [[ -d "$EXEC_DIR" && "$FORCE" != true ]]; then
    # Check if STATE.json exists - if so, we can resume
    if [[ -f "$STATE_FILE" ]]; then
        echo "INFO: Execution already initialized. Use --force to reinitialize." >&2
        cat "$STATE_FILE"
        exit 0
    fi
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Compute plan hash for drift detection
PLAN_HASH=$(sha256sum "$PLAN_FILE" | cut -d' ' -f1)
TODO_HASH=$(sha256sum "$TODO_FILE" | cut -d' ' -f1)

# Extract skill name from plan
SKILL_NAME=$(get_frontmatter_field "$PLAN_FILE" "skill_name")

# Create exec directory
mkdir -p "$EXEC_DIR"

# Parse TODO.md tasks into structured JSON
echo "=== Parsing plan artifacts ===" >&2

TASKS_JSON="[]"
if command -v jq &>/dev/null; then
    # Parse TODO table
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*T[0-9]+ ]]; then
            task_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
            description=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
            status=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
            depends_on=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
            source_section=$(echo "$line" | awk -F'|' '{print $6}' | xargs)
            
            task_obj=$(jq -n \
                --arg id "$task_id" \
                --arg desc "$description" \
                --arg status "$status" \
                --arg deps "$depends_on" \
                --arg source "$source_section" \
                '{id: $id, description: $desc, status: $status, depends_on: $deps, source_section: $source}')
            
            TASKS_JSON=$(echo "$TASKS_JSON" | jq --argjson task "$task_obj" '. += [$task]')
        fi
    done < "$TODO_FILE"
fi

# Count tasks
TASK_COUNT=$(echo "$TASKS_JSON" | jq 'length')
PENDING_COUNT=$(echo "$TASKS_JSON" | jq '[.[] | select(.status == "pending")] | length')
DONE_COUNT=$(echo "$TASKS_JSON" | jq '[.[] | select(.status == "done")] | length')

# Create PLAN_PARSED.json
cat > "$PARSED_FILE" << EOF
{
  "source": {
    "plan_path": "$PLAN_FILE",
    "plan_hash": "$PLAN_HASH",
    "todo_path": "$TODO_FILE",
    "todo_hash": "$TODO_HASH",
    "scaffold_path": "$SCAFFOLD_FILE",
    "parsed_at": "$TIMESTAMP"
  },
  "skill_name": "$SKILL_NAME",
  "tasks": $TASKS_JSON,
  "summary": {
    "total": $TASK_COUNT,
    "pending": $PENDING_COUNT,
    "done": $DONE_COUNT
  }
}
EOF

echo "Created $PARSED_FILE" >&2

# Create STATE.json
cat > "$STATE_FILE" << EOF
{
  "skill_name": "$SKILL_NAME",
  "source_plan": "$PLAN_FILE",
  "source_plan_hash": "$PLAN_HASH",
  "source_todo": "$TODO_FILE",
  "source_todo_hash": "$TODO_HASH",
  "initialized_at": "$TIMESTAMP",
  "current_task": null,
  "completed_tasks": [],
  "execution_log": []
}
EOF

echo "Created $STATE_FILE" >&2

# Create RECEIPT.md if it doesn't exist
if [[ ! -f "$RECEIPT_FILE" ]]; then
    cat > "$RECEIPT_FILE" << EOF
---
description: "Execution receipts for ${SKILL_NAME}"
timestamp: "${TIMESTAMP}"
source_plan: "${PLAN_FILE}"
---

# Execution Receipts: ${SKILL_NAME}

## Log

<!-- Receipts appended below by scripts/append-receipt.sh -->

EOF
    echo "Created $RECEIPT_FILE" >&2
fi

# Emit receipt
cat << EOF
{
  "action": "asi-exec-init",
  "status": "complete",
  "timestamp": "$TIMESTAMP",
  "skill_name": "$SKILL_NAME",
  "source_plan": "$PLAN_FILE",
  "source_plan_hash": "$PLAN_HASH",
  "task_summary": {
    "total": $TASK_COUNT,
    "pending": $PENDING_COUNT,
    "done": $DONE_COUNT
  },
  "created": [
    "$PARSED_FILE",
    "$STATE_FILE",
    "$RECEIPT_FILE"
  ],
  "next_action": "Run scripts/select-task.sh to get next task, then execute"
}
EOF
