#!/usr/bin/env bash
set -euo pipefail

# asi-plan validation script
# Read-only checks for skill preconditions

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  kickoff-approved  Check if KICKOFF.md exists with status: approved
  plan              Check if PLAN.md exists and has valid frontmatter
  todo              Check if TODO.md exists and has valid frontmatter
  kickoff-drift     Check if KICKOFF.md has changed since PLAN.md was created
  plan-drift        Check if PLAN.md has changed since TODO.md was created
  traceability      Check if all TODO tasks have source_section

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

check_kickoff_approved() {
    local kickoff_file="${TARGET_DIR:-./KICKOFF.md}"
    
    if [[ ! -f "$kickoff_file" ]]; then
        echo "KICKOFF.md not found"
        exit 1
    fi
    
    # Check for valid frontmatter
    if ! head -1 "$kickoff_file" | grep -q '^---$'; then
        echo "KICKOFF.md missing frontmatter"
        exit 1
    fi
    
    # Check for status: approved
    if ! grep -q '^status: approved' "$kickoff_file"; then
        local status=$(grep '^status:' "$kickoff_file" | head -1 | cut -d':' -f2 | tr -d ' ')
        echo "KICKOFF.md status is '${status}', not 'approved'"
        exit 1
    fi
    
    echo "KICKOFF.md exists with status: approved"
    exit 0
}

check_plan() {
    local plan_file="${TARGET_DIR:-./PLAN.md}"
    
    if [[ ! -f "$plan_file" ]]; then
        echo "PLAN.md not found"
        exit 1
    fi
    
    if ! head -1 "$plan_file" | grep -q '^---$'; then
        echo "PLAN.md missing frontmatter"
        exit 1
    fi
    
    if ! grep -q '^status:' "$plan_file"; then
        echo "PLAN.md missing status field"
        exit 1
    fi
    
    echo "PLAN.md exists with valid frontmatter"
    exit 0
}

check_todo() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    if ! head -1 "$todo_file" | grep -q '^---$'; then
        echo "TODO.md missing frontmatter"
        exit 1
    fi
    
    if ! grep -q '^status:' "$todo_file"; then
        echo "TODO.md missing status field"
        exit 1
    fi
    
    echo "TODO.md exists with valid frontmatter"
    exit 0
}

check_kickoff_drift() {
    local plan_file="${TARGET_DIR:-./PLAN.md}"
    local kickoff_file="${TARGET_DIR:-./KICKOFF.md}"
    
    if [[ ! -f "$plan_file" ]]; then
        echo "PLAN.md not found"
        exit 1
    fi
    
    if [[ ! -f "$kickoff_file" ]]; then
        echo "KICKOFF.md not found"
        exit 1
    fi
    
    # Extract stored hash from PLAN.md frontmatter
    local stored_hash=$(grep '^source_kickoff_hash:' "$plan_file" | head -1 | cut -d'"' -f2)
    if [[ -z "$stored_hash" ]]; then
        echo "PLAN.md missing source_kickoff_hash field"
        exit 1
    fi
    
    # Compute current hash of KICKOFF.md
    local current_hash=$(sha256sum "$kickoff_file" | cut -d' ' -f1)
    
    if [[ "$stored_hash" != "$current_hash" ]]; then
        echo "KICKOFF.md has changed since PLAN.md was created"
        echo "  Stored hash:  $stored_hash"
        echo "  Current hash: $current_hash"
        exit 1
    fi
    
    echo "KICKOFF.md unchanged (hash matches)"
    exit 0
}

check_plan_drift() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    local plan_file="${TARGET_DIR:-./PLAN.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    if [[ ! -f "$plan_file" ]]; then
        echo "PLAN.md not found"
        exit 1
    fi
    
    # Extract stored hash from TODO.md frontmatter
    local stored_hash=$(grep '^source_plan_hash:' "$todo_file" | head -1 | cut -d'"' -f2)
    if [[ -z "$stored_hash" ]]; then
        echo "TODO.md missing source_plan_hash field"
        exit 1
    fi
    
    # Compute current hash of PLAN.md
    local current_hash=$(sha256sum "$plan_file" | cut -d' ' -f1)
    
    if [[ "$stored_hash" != "$current_hash" ]]; then
        echo "PLAN.md has changed since TODO.md was created"
        echo "  Stored hash:  $stored_hash"
        echo "  Current hash: $current_hash"
        exit 1
    fi
    
    echo "PLAN.md unchanged (hash matches)"
    exit 0
}

check_traceability() {
    local todo_file="${TARGET_DIR:-./TODO.md}"
    
    if [[ ! -f "$todo_file" ]]; then
        echo "TODO.md not found"
        exit 1
    fi
    
    # Check if any task rows exist without source_section
    # Tasks are in table format: | ID | Description | Status | Depends On | Source Section |
    # We look for rows where the last column (Source Section) is empty
    local missing_trace=0
    local task_count=0
    
    while IFS= read -r line; do
        # Skip header and separator rows
        if [[ "$line" =~ ^\|[[:space:]]*ID || "$line" =~ ^\|[[:space:]]*-+ ]]; then
            continue
        fi
        # Check if this is a task row (starts with | and has task ID pattern)
        if [[ "$line" =~ ^\|[[:space:]]*T[0-9]+ ]]; then
            ((task_count++))
            # Get the last column (Source Section)
            local source_section=$(echo "$line" | awk -F'|' '{print $(NF-1)}' | xargs)
            if [[ -z "$source_section" ]]; then
                echo "Task missing source_section: $line"
                ((missing_trace++))
            fi
        fi
    done < "$todo_file"
    
    if [[ $task_count -eq 0 ]]; then
        echo "No tasks found in TODO.md"
        exit 1
    fi
    
    if [[ $missing_trace -gt 0 ]]; then
        echo "$missing_trace of $task_count tasks missing source_section"
        exit 1
    fi
    
    echo "All $task_count tasks have source_section (traceability verified)"
    exit 0
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            kickoff-approved) check_kickoff_approved ;;
            plan) check_plan ;;
            todo) check_todo ;;
            kickoff-drift) check_kickoff_drift ;;
            plan-drift) check_plan_drift ;;
            traceability) check_traceability ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
