#!/usr/bin/env bash
set -euo pipefail

# asi-kickoff validation script
# Read-only checks for skill preconditions

usage() {
    cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  kickoff           Check if KICKOFF.md exists and has valid frontmatter
  questions         Check if QUESTIONS.md exists and check resolution status

Exit codes:
  0  Check passed
  1  Check failed
  2  Invalid arguments
EOF
    exit 2
}

check_questions() {
    local questions_file="${TARGET_DIR:-./QUESTIONS.md}"
    
    if [[ ! -f "$questions_file" ]]; then
        echo "QUESTIONS.md not found"
        exit 1
    fi
    
    # Check for unresolved questions (unchecked boxes)
    local unresolved=$(grep -c '^- \[ \]' "$questions_file" 2>/dev/null || echo "0")
    local resolved=$(grep -c '^- \[x\]' "$questions_file" 2>/dev/null || echo "0")
    
    # Check frontmatter status
    local status=$(grep '^status:' "$questions_file" | head -1 | awk '{print $2}')
    
    echo "QUESTIONS.md: $resolved resolved, $unresolved unresolved (status: $status)"
    
    if [[ "$unresolved" -gt 0 ]]; then
        echo "Unresolved questions remain"
        exit 1
    fi
    
    exit 0
}

check_kickoff() {
    local kickoff_file="${TARGET_DIR:-./KICKOFF.md}"
    
    if [[ ! -f "$kickoff_file" ]]; then
        echo "KICKOFF.md not found"
        exit 1
    fi
    
    # Check for valid frontmatter (starts with ---)
    if ! head -1 "$kickoff_file" | grep -q '^---$'; then
        echo "KICKOFF.md missing frontmatter"
        exit 1
    fi
    
    # Check for required frontmatter fields
    if ! grep -q '^status:' "$kickoff_file"; then
        echo "KICKOFF.md missing status field"
        exit 1
    fi
    
    echo "KICKOFF.md exists with valid frontmatter"
    exit 0
}

# Parse arguments
[[ $# -lt 2 ]] && usage

case "$1" in
    --check)
        case "$2" in
            kickoff) check_kickoff ;;
            questions) check_questions ;;
            *) echo "Unknown check: $2"; usage ;;
        esac
        ;;
    *)
        usage
        ;;
esac
