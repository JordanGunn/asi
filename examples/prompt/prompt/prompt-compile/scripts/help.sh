#!/usr/bin/env bash
cat <<'EOF'
prompt-compile - Compile .prompt/active.yaml into .prompt/PROMPT.md

Scripts:
  compile.sh   Compile the YAML artifact to markdown
  validate.sh  Verify the skill is runnable (read-only)

Usage:
  ./compile.sh [--dry-run]
  ./validate.sh

Deterministic behavior:
- Verifies active artifact exists
- Validates artifact (schema)
- Writes .prompt/PROMPT.md (unless --dry-run)
- Preserves active artifact
EOF
