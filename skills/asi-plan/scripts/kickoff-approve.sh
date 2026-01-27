#!/usr/bin/env bash
set -euo pipefail

# asi-plan kickoff-phase approval script
# Updates KICKOFF.md status field to 'approved'

ASI_DIR=".asi/kickoff"
KICKOFF_FILE="$ASI_DIR/KICKOFF.md"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--check | --approve]

Options:
  --check     Check if KICKOFF.md is ready for approval
  --approve   Set KICKOFF.md status to 'approved'

Exit codes:
  0  Success
  1  Failure (file missing, not ready, etc.)
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

check_ready() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi

    local status
    status=$(get_frontmatter_field "$KICKOFF_FILE" "status")
    
    if [[ "$status" == "approved" ]]; then
        echo "PASS: Already approved"
        return 0
    fi

    if [[ "$status" != "draft" && "$status" != "review" ]]; then
        echo "FAIL: Unexpected status '$status'"
        return 1
    fi

    # Check required sections exist
    local missing=0
    for section in "Purpose" "Deterministic Surface" "Judgment Remainder" "Schema Designs"; do
        if ! grep -q "^## $section" "$KICKOFF_FILE"; then
            echo "FAIL: Missing section: $section"
            missing=1
        fi
    done

    if [[ "$missing" -eq 1 ]]; then
        return 1
    fi

    echo "READY: status=$status, all sections present"
    return 0
}

do_approve() {
    if [[ ! -f "$KICKOFF_FILE" ]]; then
        echo "FAIL: $KICKOFF_FILE does not exist"
        return 1
    fi

    local status
    status=$(get_frontmatter_field "$KICKOFF_FILE" "status")

    if [[ "$status" == "approved" ]]; then
        echo "PASS: Already approved"
        return 0
    fi

    # Update status in frontmatter
    if sed_inplace "s/^status:[[:space:]]*${status}$/status: approved/" "$KICKOFF_FILE"; then
        echo "PASS: Updated status from '$status' to 'approved'"
        return 0
    else
        echo "FAIL: Could not update status"
        return 1
    fi
}

[[ $# -lt 1 ]] && usage

case "$1" in
    --check)
        check_ready
        ;;
    --approve)
        check_ready && do_approve
        ;;
    *)
        usage
        ;;
esac
