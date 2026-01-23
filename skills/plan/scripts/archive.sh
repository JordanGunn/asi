#!/usr/bin/env bash
set -euo pipefail

# plan skill - archive.sh
# Archives the current plan and clears active

PLAN_DIR=".plan"
ACTIVE_FILE="$PLAN_DIR/active.yaml"
STATE_FILE="$PLAN_DIR/active/STATE.json"
ARCHIVE_DIR="$PLAN_DIR/archive"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--force]

Arguments:
  --force   Archive even if steps are incomplete.

Exit codes:
  0  Plan archived successfully
  1  Archive failed
  2  Invalid arguments
EOF
    exit 2
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

# Check prerequisites
if [[ ! -f "$ACTIVE_FILE" ]]; then
    echo "ERROR: No active plan to archive." >&2
    exit 1
fi

# Check for incomplete steps
INCOMPLETE=$(grep -c "status: pending\|status: in_progress" "$ACTIVE_FILE" 2>/dev/null || echo "0")

if [[ "$INCOMPLETE" -gt 0 && "$FORCE" != true ]]; then
    echo "ERROR: $INCOMPLETE incomplete steps. Use --force to archive anyway." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ARCHIVE_NAME=$(date -u +"%Y%m%d_%H%M%S")
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

# Create archive directory
mkdir -p "$ARCHIVE_PATH"

# Move files to archive
mv "$ACTIVE_FILE" "$ARCHIVE_PATH/"
if [[ -f "$STATE_FILE" ]]; then
    mv "$STATE_FILE" "$ARCHIVE_PATH/"
fi

# Clean up active directory
rmdir "$PLAN_DIR/active" 2>/dev/null || true

# Get plan name from archived file
PLAN_NAME=$(grep "^name:" "$ARCHIVE_PATH/active.yaml" | sed 's/name:[[:space:]]*//' | tr -d '"')

cat << EOF
{
  "action": "plan-archive",
  "status": "success",
  "timestamp": "$TIMESTAMP",
  "plan_name": "$PLAN_NAME",
  "archive_path": "$ARCHIVE_PATH",
  "message": "Plan '$PLAN_NAME' archived to $ARCHIVE_PATH"
}
EOF
