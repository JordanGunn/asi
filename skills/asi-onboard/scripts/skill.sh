#!/usr/bin/env bash
# asi-onboard skill wrapper - delegates to asi CLI
set -euo pipefail

cmd_help() {
    cat <<'EOF'
asi-onboard - Establish repository context (CLI-owned)

Commands:
  help                         Show this help message
  init                         Emit all skill reference docs (concatenated)
  validate                     Verify the skill is runnable (read-only)
  schema                       Emit JSON schema for plan input
  run --stdin                  Execute onboard via plan JSON

Execution backend: asi CLI
EOF
}

cmd_init() {
    asi skill init --skill-dir "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

cmd_validate() {
    if ! command -v asi &>/dev/null; then
        echo "error: asi CLI not found. Install from skills/cli/." >&2
        return 1
    fi
    asi doctor
}

cmd_schema() {
    asi onboard --schema
}

cmd_run() {
    asi onboard run --stdin
}

case "${1:-help}" in
    help) cmd_help ;;
    init) cmd_init ;;
    validate) cmd_validate ;;
    schema) cmd_schema ;;
    run) cmd_run ;;
    *) echo "error: unknown command '$1'" >&2; exit 1 ;;
esac
