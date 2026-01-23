#!/usr/bin/env bash
set -euo pipefail

# plan skill - status.sh
# Displays current plan status

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--format <json|text>]

Arguments:
  --format   Optional. Output format: json or text (default: text).

Exit codes:
  0  Success
  1  No active plan
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
FORMAT="text"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            FORMAT="$2"
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

# Check prerequisites
if [[ ! -f "$ACTIVE_FILE" ]]; then
    echo "ERROR: No active plan." >&2
    exit 1
fi

# Count steps by status
TOTAL=0
PENDING=0
IN_PROGRESS=0
DONE=0
SKIPPED=0

while IFS= read -r line; do
    if [[ "$line" =~ status:[[:space:]]*(pending|in_progress|done|skipped) ]]; then
        status="${BASH_REMATCH[1]}"
        ((TOTAL++))
        case "$status" in
            pending) ((PENDING++)) ;;
            in_progress) ((IN_PROGRESS++)) ;;
            done) ((DONE++)) ;;
            skipped) ((SKIPPED++)) ;;
        esac
    fi
done < "$ACTIVE_FILE"

# Get plan name
PLAN_NAME=$(grep "^name:" "$ACTIVE_FILE" | sed 's/name:[[:space:]]*//' | tr -d '"')
PLAN_STATUS=$(grep "^status:" "$ACTIVE_FILE" | head -1 | sed 's/status:[[:space:]]*//')

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ "$FORMAT" == "json" ]]; then
    cat << EOF
{
  "action": "plan-status",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "plan_name": "$PLAN_NAME",
  "plan_status": "$PLAN_STATUS",
  "summary": {
    "total_steps": $TOTAL,
    "pending": $PENDING,
    "in_progress": $IN_PROGRESS,
    "done": $DONE,
    "skipped": $SKIPPED
  }
}
EOF
else
    echo "=== Plan: $PLAN_NAME ==="
    echo "Status: $PLAN_STATUS"
    echo ""
    echo "Steps: $TOTAL total"
    echo "  - Pending:     $PENDING"
    echo "  - In Progress: $IN_PROGRESS"
    echo "  - Done:        $DONE"
    echo "  - Skipped:     $SKIPPED"
    echo ""
    
    # Show step list
    echo "--- Steps ---"
    current_step=""
    while IFS= read -r line; do
        if [[ "$line" =~ id:[[:space:]]*\"?([^\"]+)\"? ]]; then
            current_step="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ description:[[:space:]]*\"?(.+)\"?$ ]]; then
            desc="${BASH_REMATCH[1]}"
            desc="${desc%\"}"
        elif [[ "$line" =~ status:[[:space:]]*(pending|in_progress|done|skipped) ]]; then
            status="${BASH_REMATCH[1]}"
            case "$status" in
                pending) icon="○" ;;
                in_progress) icon="◐" ;;
                done) icon="●" ;;
                skipped) icon="⊘" ;;
            esac
            echo "$icon $current_step: $desc"
        fi
    done < "$ACTIVE_FILE"
fi
