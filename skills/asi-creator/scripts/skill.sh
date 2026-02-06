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
  schema [run|suggest|apply]   Emit JSON schema (default: run)
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
        echo "error: asi CLI not found. Install from skills/cli/." >&2
        return 1
    fi
    asi doctor
}

cmd_schema() {
    case "${1:-run}" in
        run)
            asi creator --schema
            ;;
        suggest)
            asi creator suggest --schema
            ;;
        apply)
            asi creator apply --schema
            ;;
        *)
            echo "error: unknown schema target '$1' (expected: run|suggest|apply)" >&2
            return 1
            ;;
    esac
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
    schema) shift; cmd_schema "${1:-run}" ;;
    run) cmd_run ;;
    next) cmd_next ;;
    suggest) cmd_suggest ;;
    apply) cmd_apply ;;
    *) echo "error: unknown command '$1'" >&2; exit 1 ;;
esac
