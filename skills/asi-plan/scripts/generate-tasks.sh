#!/usr/bin/env bash
set -euo pipefail

# asi-plan task generation script
# Deterministically generates tasks from SCAFFOLD.json
# Agent reviews/augments; does not invent from scratch

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
SCAFFOLD_FILE="$KICKOFF_DIR/SCAFFOLD.json"
SKILL_TYPE_FILE="$KICKOFF_DIR/SKILL_TYPE.json"
TASKS_FILE="$PLAN_DIR/tasks_scaffold.json"

usage() {
    cat <<EOF
Usage: $(basename "$0")

This script:
  1. Reads SCAFFOLD.json from kickoff
  2. Deterministically generates task list for directory/file creation
  3. Outputs structured JSON to .asi/plan/tasks_scaffold.json
  4. Agent reviews and augments (does not replace)

Exit codes:
  0  Task generation complete
  1  Generation failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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
if [[ ! -f "$SCAFFOLD_FILE" ]]; then
    echo "ERROR: $SCAFFOLD_FILE does not exist." >&2
    exit 1
fi

if [[ ! -d "$PLAN_DIR" ]]; then
    echo "ERROR: $PLAN_DIR does not exist. Run init.sh first." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required for task generation. Run scripts/bootstrap.sh --check for install guidance." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get skill type
SKILL_TYPE=$(jq -r '.type // "single"' "$SKILL_TYPE_FILE" 2>/dev/null || echo "single")

# Generate tasks from scaffold
echo "=== Generating tasks from SCAFFOLD.json ===" >&2

# Extract structure from scaffold
STRUCTURE=$(jq -r '.structure // empty' "$SCAFFOLD_FILE")

if [[ -z "$STRUCTURE" || "$STRUCTURE" == "null" ]]; then
    echo "WARN: SCAFFOLD.json structure is empty or null" >&2
    # Create minimal task list
    cat > "$TASKS_FILE" << EOF
{
  "generated_at": "$TIMESTAMP",
  "source": "$SCAFFOLD_FILE",
  "skill_type": "$SKILL_TYPE",
  "tasks": [],
  "warnings": ["SCAFFOLD.json structure is empty"]
}
EOF
    echo "Created $TASKS_FILE (empty)" >&2
    exit 0
fi

# Generate task list from scaffold
TASK_ID=1

append_task() {
    local type="$1"
    local path="$2"
    local description="$3"
    local source="$4"
    local id

    id=$(printf "T%03d" "$TASK_ID")
    TASK_ID=$((TASK_ID + 1))

    if [[ "$TASKS" != "[" ]]; then
        TASKS+="," 
    fi

    TASKS+=$(cat << EOF
    {
      "id": "$id",
      "type": "$type",
      "path": "$path",
      "description": "$description",
      "status": "pending",
      "depends_on": [],
      "source_section": "$source"
    }
EOF
)
}

# Start building tasks array
TASKS="["

# Directories declared by SCAFFOLD.json (relative to target_directory)
mapfile -t SCAFFOLD_DIRS < <(jq -r '.structure.directories[]? // empty' "$SCAFFOLD_FILE")
for dir in "${SCAFFOLD_DIRS[@]}"; do
    append_task "directory" "$dir" "Create $dir directory" "SCAFFOLD.json"
done

# Files declared by SCAFFOLD.json (relative to target_directory)
mapfile -t SCAFFOLD_FILES < <(jq -r '.structure.files[]?.path // empty' "$SCAFFOLD_FILE")
for file in "${SCAFFOLD_FILES[@]}"; do
    append_task "file" "$file" "Create $file" "SCAFFOLD.json"
done

TASKS+="]"

# Write tasks file
cat > "$TASKS_FILE" << EOF
{
  "generated_at": "$TIMESTAMP",
  "source": "$SCAFFOLD_FILE",
  "skill_type": "$SKILL_TYPE",
  "task_count": $((TASK_ID - 1)),
  "tasks": $TASKS
}
EOF

echo "Created $TASKS_FILE with $((TASK_ID - 1)) tasks" >&2

# Emit receipt
cat << EOF
{
  "action": "asi-plan-generate-tasks",
  "status": "complete",
  "timestamp": "$TIMESTAMP",
  "source": "$SCAFFOLD_FILE",
  "output": "$TASKS_FILE",
  "task_count": $((TASK_ID - 1)),
  "next_action": "Review tasks_scaffold.json, then fill PLAN.md sections"
}
EOF
