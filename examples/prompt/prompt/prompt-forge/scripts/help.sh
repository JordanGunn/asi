#!/usr/bin/env bash
cat <<'EOF'
prompt-forge - Shape and stabilize intent into .prompt/active.yaml

Scripts:
  forge.sh     Run the prompt forge operation
  validate.sh  Verify the skill is runnable (read-only)
  help.sh      Show this help message

Usage:
  ./forge.sh [--mark-ready]
  ./validate.sh

Deterministic behavior:
- Ensures .prompt/active.yaml exists (creates it if missing)
- Prints current artifact status
- Optionally marks artifact ready (requires no open questions, and requires a prompt)
EOF
