#!/usr/bin/env bash
set -euo pipefail

# plan skill - add-step.sh
# Adds a step to the active plan

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --step <description> [--after <step-id>]

Arguments:
  --step   Required. Step description.
  --after  Optional. Insert after this step ID (e.g., S001).

Exit codes:
  0  Step added successfully
  1  Addition failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
STEP_DESC=""
AFTER_STEP=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --step)
            STEP_DESC="$2"
            shift 2
            ;;
        --after)
            AFTER_STEP="$2"
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

if [[ -z "$STEP_DESC" ]]; then
    echo "ERROR: --step is required" >&2
    usage
fi

# Check prerequisites
if [[ ! -f "$ACTIVE_FILE" ]]; then
    echo "ERROR: No active plan. Run init.sh first." >&2
    exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
    echo "ERROR: STATE.json missing." >&2
    exit 1
fi

# Always use fallback method (yq has version incompatibilities)
if true; then
    # Fallback without yq - use simple append
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get next step number from STATE.json
    if command -v jq &>/dev/null; then
        STEP_NUM=$(jq -r '.step_counter' "$STATE_FILE")
        STEP_NUM=$((STEP_NUM + 1))
        STEP_ID=$(printf "S%03d" $STEP_NUM)
        
        # Update step counter
        jq --argjson num "$STEP_NUM" --arg ts "$TIMESTAMP" \
            '.step_counter = $num | .last_modified = $ts | .log += [{"event": "step_added", "step_id": "'"$STEP_ID"'", "timestamp": $ts}]' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        STEP_ID="S001"
    fi
    
    # Append step to YAML (simple approach)
    cat >> "$ACTIVE_FILE" << EOF

  - id: "${STEP_ID}"
    description: "${STEP_DESC}"
    status: pending
    created_at: "${TIMESTAMP}"
EOF
    
    # Fix YAML structure if needed (replace empty steps array)
    sed -i 's/^steps: \[\]$/steps:/' "$ACTIVE_FILE"
    
    cat << EOF
{
  "action": "plan-add-step",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "step_id": "$STEP_ID",
  "description": "$STEP_DESC",
  "message": "Step $STEP_ID added"
}
EOF
    exit 0
fi

# With yq available
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STEP_NUM=$(jq -r '.step_counter' "$STATE_FILE")
STEP_NUM=$((STEP_NUM + 1))
STEP_ID=$(printf "S%03d" $STEP_NUM)

# Add step using yq
yq -i ".steps += [{\"id\": \"$STEP_ID\", \"description\": \"$STEP_DESC\", \"status\": \"pending\", \"created_at\": \"$TIMESTAMP\"}]" "$ACTIVE_FILE"

# Update state
jq --argjson num "$STEP_NUM" --arg ts "$TIMESTAMP" --arg id "$STEP_ID" \
    '.step_counter = $num | .last_modified = $ts | .log += [{"event": "step_added", "step_id": $id, "timestamp": $ts}]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

cat << EOF
{
  "action": "plan-add-step",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "step_id": "$STEP_ID",
  "description": "$STEP_DESC",
  "message": "Step $STEP_ID added"
}
EOF
