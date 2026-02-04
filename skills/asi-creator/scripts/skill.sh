#!/usr/bin/env bash
# asi-creator skill wrapper - delegates to asi CLI
set -euo pipefail

cmd_help() {
    cat <<'EOF'
asi-creator - Create ASI-compliant skills (CLI-owned)

Commands:
  help                         Show this help message
  init                         Emit all skill reference docs (concatenated)
  validate                     Verify the skill is runnable (read-only)
  schema                       Emit JSON schema for plan input
  run --stdin                  Execute creator via plan JSON
  next                         Emit next questions (interactive loop)
  suggest --stdin              Validate agent suggestions
  apply --stdin                Apply user answers

Execution backend: asi CLI
EOF
}

cmd_init() {
    asi skill init --skill-dir "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

cmd_validate() {
    if ! command -v asi &>/dev/null; then
        echo "error: asi CLI not found. Install from cli/." >&2
        return 1
    fi
    asi doctor
}

cmd_schema() {
    asi creator --schema
}

cmd_run() {
    asi creator run --stdin
}

cmd_next() {
    asi creator next
}

cmd_suggest() {
    asi creator suggest --stdin
}

cmd_apply() {
    asi creator apply --stdin
}

case "${1:-help}" in
    help) cmd_help ;;
    init) cmd_init ;;
    validate) cmd_validate ;;
    schema) cmd_schema ;;
    run) cmd_run ;;
    next) cmd_next ;;
    suggest) cmd_suggest ;;
    apply) cmd_apply ;;
    *) echo "error: unknown command '$1'" >&2; exit 1 ;;
esac
