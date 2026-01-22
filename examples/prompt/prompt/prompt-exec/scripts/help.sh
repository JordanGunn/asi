#!/usr/bin/env bash
cat <<'EOF'
prompt-exec - Execute the forged prompt exactly as written

Scripts:
  exec.sh      Execute the prompt
  validate.sh  Verify the skill is runnable (read-only)

Usage:
  ./exec.sh [--dry-run]
  ./validate.sh

Deterministic behavior:
- Requires .prompt/active.yaml exists
- Requires artifact status is ready
- Writes receipt to .prompt/receipts/
- Deletes .prompt/active.yaml after successful execution
- Prints the prompt text to execute
EOF
