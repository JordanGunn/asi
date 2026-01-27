#!/usr/bin/env bash
set -euo pipefail

# asi-onboard validation script
# Read-only deterministic checks for onboarding artifacts

ASI_DIR=".asi/onboard"
NOTES_FILE="$ASI_DIR/NOTES.md"
SOURCES_FILE="$ASI_DIR/SOURCES.md"
STATE_FILE="$ASI_DIR/STATE.json"

usage() {
  cat <<EOF
Usage: $(basename "$0") --check <check-type>

Check types:
  dir-exists     .asi/onboard/ directory exists
  notes-exists   NOTES.md exists
  sources-exists SOURCES.md exists
  state-exists   STATE.json exists
  session        All core artifacts exist
  all            Same as session
EOF
  exit 2
}

get_check="${2:-}"
if [[ "${1:-}" != "--check" || -z "$get_check" ]]; then
  usage
fi

check_dir_exists() {
  [[ -d "$ASI_DIR" ]] && echo "PASS: $ASI_DIR exists" && return 0
  echo "FAIL: $ASI_DIR does not exist" && return 1
}

check_notes_exists() {
  [[ -f "$NOTES_FILE" ]] && echo "PASS: $NOTES_FILE exists" && return 0
  echo "FAIL: $NOTES_FILE does not exist" && return 1
}

check_sources_exists() {
  [[ -f "$SOURCES_FILE" ]] && echo "PASS: $SOURCES_FILE exists" && return 0
  echo "FAIL: $SOURCES_FILE does not exist" && return 1
}

check_state_exists() {
  [[ -f "$STATE_FILE" ]] && echo "PASS: $STATE_FILE exists" && return 0
  echo "FAIL: $STATE_FILE does not exist" && return 1
}

case "$get_check" in
  dir-exists) check_dir_exists ;;
  notes-exists) check_notes_exists ;;
  sources-exists) check_sources_exists ;;
  state-exists) check_state_exists ;;
  session|all)
    failed=0
    check_dir_exists || failed=1
    check_notes_exists || failed=1
    check_sources_exists || failed=1
    check_state_exists || failed=1
    exit $failed
    ;;
  *) usage ;;
esac

