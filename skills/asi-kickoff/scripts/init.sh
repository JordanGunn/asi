#!/usr/bin/env bash
set -euo pipefail

# asi-kickoff initialization script
# Deterministic preamble: creates structure and populates known values
# Agent work happens AFTER this script completes

ASI_DIR=".asi/kickoff"
KICKOFF_FILE="$ASI_DIR/KICKOFF.md"
QUESTIONS_FILE="$ASI_DIR/QUESTIONS.md"
SKILL_TYPE_FILE="$ASI_DIR/SKILL_TYPE.json"
SCAFFOLD_FILE="$ASI_DIR/SCAFFOLD.json"
STATE_FILE="$ASI_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") --skill-name <name> --skill-purpose <purpose> [--target <dir>] [--force]

Arguments:
  --skill-name     Required. Name of the skill being designed.
  --skill-purpose  Required. One-line purpose of the skill.
  --target         Optional. Target directory. Defaults to current directory.
  --force          Optional. Remove existing .asi/kickoff/ and reinitialize.

This script:
  1. Creates .asi/kickoff/ directory
  2. Populates KICKOFF.md with deterministic values (timestamp, name, purpose, structure)
  3. Creates empty SKILL_TYPE.json and SCAFFOLD.json for agent to fill
  4. Creates STATE.json to track procedure progress
  5. Emits receipt to stdout

Exit codes:
  0  Initialization complete
  1  Initialization failed
  2  Invalid arguments
EOF
    exit 2
}

# Parse arguments
SKILL_NAME=""
SKILL_PURPOSE=""
TARGET_DIR=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skill-name)
            SKILL_NAME="$2"
            shift 2
            ;;
        --skill-purpose)
            SKILL_PURPOSE="$2"
            shift 2
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            ;;
    esac
done

# Default target: git repo root (if available), otherwise current directory.
if [[ -z "$TARGET_DIR" ]]; then
    if TARGET_DIR=$(git rev-parse --show-toplevel 2>/dev/null); then
        :
    else
        TARGET_DIR="."
    fi
fi

# Validate required arguments
if [[ -z "$SKILL_NAME" ]]; then
    echo "ERROR: --skill-name is required" >&2
    usage
fi

if [[ -z "$SKILL_PURPOSE" ]]; then
    echo "ERROR: --skill-purpose is required" >&2
    usage
fi

# Change to target directory
cd "$TARGET_DIR" || { echo "ERROR: Cannot access target directory: $TARGET_DIR" >&2; exit 1; }

# Check if already initialized
if [[ -d "$ASI_DIR" ]]; then
    if [[ "$FORCE" == true ]]; then
        rm -rf "$ASI_DIR"
    else
        echo "ERROR: $ASI_DIR already exists. Use --force to reinitialize or remove manually." >&2
        exit 1
    fi
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create directory structure
mkdir -p "$ASI_DIR"

# Create KICKOFF.md with deterministic values
cat > "$KICKOFF_FILE" << EOF
---
description: "Skill design kickoff for ${SKILL_NAME}"
timestamp: "${TIMESTAMP}"
status: draft
skill_name: "${SKILL_NAME}"
skill_purpose: "${SKILL_PURPOSE}"
step: 0
---

# Kickoff: ${SKILL_NAME}

## Purpose

### What this skill does

<!-- AGENT: Fill this section -->

### What problem it solves

<!-- AGENT: Fill this section -->

### What this skill does NOT do

<!-- AGENT: Fill this section -->

### Governing ASI principles

<!-- AGENT: Fill this section -->

---

## Deterministic Surface

### Mechanisms

<!-- AGENT: Fill this table -->

| Mechanism | Inputs | Outputs | Failure Conditions | Idempotent |
| --------- | ------ | ------- | ------------------ | ---------- |
|           |        |         |                    |            |

### Observable Signals

<!-- AGENT: Fill this section -->

---

## Judgment Remainder

### Items requiring judgment

<!-- AGENT: Fill this table -->

| Decision | Why Not Deterministic | Category | Blocking Reason |
| -------- | --------------------- | -------- | --------------- |
|          |                       |          |                 |

### Disallowed shortcuts

<!-- AGENT: Fill this section -->

---

## Schema Designs

### Intent Schema

<!-- AGENT: Fill this section -->

\`\`\`json
{
  "\$comment": "Shape only - no logic"
}
\`\`\`

### Execution Plan Schema

<!-- AGENT: Fill this section -->

\`\`\`json
{
  "\$comment": "Shape only - no logic"
}
\`\`\`

### Result Schema

<!-- AGENT: Fill this section -->

\`\`\`json
{
  "\$comment": "Shape only - no logic"
}
\`\`\`

---

## Open Questions

<!-- AGENT: Capture only - do not answer -->

- [ ] 

EOF

# Create QUESTIONS.md
cat > "$QUESTIONS_FILE" << EOF
---
timestamp: "${TIMESTAMP}"
skill_name: "${SKILL_NAME}"
---

# Open Questions: ${SKILL_NAME}

Questions captured during kickoff. Do not answer—capture only.

## Unresolved

- [ ] 

## Resolved

<!-- Move resolved questions here with answers -->

EOF

# Create SKILL_TYPE.json (agent fills type field)
cat > "$SKILL_TYPE_FILE" << EOF
{
  "\$schema": "../assets/schemas/skill_type_v1.schema.json",
  "skill_name": "${SKILL_NAME}",
  "type": null,
  "reasoning": null,
  "timestamp": "${TIMESTAMP}"
}
EOF

# Create SCAFFOLD.json (agent fills structure)
cat > "$SCAFFOLD_FILE" << EOF
{
  "\$schema": "../assets/schemas/single_skill_scaffold_v1.schema.json",
  "skill_name": "${SKILL_NAME}",
  "structure": null,
  "timestamp": "${TIMESTAMP}"
}
EOF

# Create STATE.json to track procedure progress
cat > "$STATE_FILE" << EOF
{
  "skill_name": "${SKILL_NAME}",
  "initialized_at": "${TIMESTAMP}",
  "current_step": 0,
  "steps": {
    "0": { "name": "init", "status": "complete", "completed_at": "${TIMESTAMP}" },
    "1": { "name": "purpose", "status": "pending", "completed_at": null },
    "2": { "name": "scaffold", "status": "pending", "completed_at": null },
    "3": { "name": "deterministic_surface", "status": "pending", "completed_at": null },
    "4": { "name": "judgment_remainder", "status": "pending", "completed_at": null },
    "5": { "name": "schemas", "status": "pending", "completed_at": null },
    "6": { "name": "questions", "status": "pending", "completed_at": null }
  }
}
EOF

# Emit receipt
cat << EOF
{
  "action": "asi-kickoff-init",
  "status": "complete",
  "timestamp": "${TIMESTAMP}",
  "skill_name": "${SKILL_NAME}",
  "skill_purpose": "${SKILL_PURPOSE}",
  "target_directory": "$(pwd)",
  "created": [
    "${KICKOFF_FILE}",
    "${QUESTIONS_FILE}",
    "${SKILL_TYPE_FILE}",
    "${SCAFFOLD_FILE}",
    "${STATE_FILE}"
  ],
  "next_step": 1,
  "next_action": "Fill Purpose section in KICKOFF.md, then run: scripts/checkpoint.sh --step 1"
}
EOF
