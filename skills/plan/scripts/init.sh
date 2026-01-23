#!/usr/bin/env bash
set -euo pipefail

# plan skill - init.sh
# Creates a new plan with the specified name

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --name <plan-name> [--force]

Arguments:
  --name   Required. Name for the new plan.
  --force  Overwrite existing plan if present.

Exit codes:
  0  Plan created successfully
  1  Creation failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
PLAN_NAME=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            PLAN_NAME="$2"
            shift 2
            ;;
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

if [[ -z "$PLAN_NAME" ]]; then
    echo "ERROR: --name is required" >&2
    usage
fi

# Check if plan already exists
if [[ -f "$ACTIVE_FILE" && "$FORCE" != true ]]; then
    echo "ERROR: Plan already exists at $ACTIVE_FILE. Use --force to overwrite." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create directory structure
mkdir -p "$PLAN_DIR/active"
mkdir -p "$PLAN_DIR/archive"

# Create active.yaml
cat > "$ACTIVE_FILE" << EOF
name: "${PLAN_NAME}"
created_at: "${TIMESTAMP}"
status: active
steps: []
EOF

# Create STATE.json
cat > "$STATE_FILE" << EOF
{
  "plan_name": "${PLAN_NAME}",
  "created_at": "${TIMESTAMP}",
  "last_modified": "${TIMESTAMP}",
  "step_counter": 0,
  "log": [
    {"event": "plan_created", "timestamp": "${TIMESTAMP}"}
  ]
}
EOF

# Emit receipt
cat << EOF
{
  "action": "plan-init",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "plan_name": "$PLAN_NAME",
  "created": ["$ACTIVE_FILE", "$STATE_FILE"],
  "message": "Plan '$PLAN_NAME' created successfully"
}
EOF
