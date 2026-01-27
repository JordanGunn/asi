#!/usr/bin/env bash
set -euo pipefail

# asi-plan initialization script
# Deterministic preamble: validates prerequisites, parses kickoff artifacts, creates structure
# Agent work happens AFTER this script completes

 TARGET_DIR="${TARGET_DIR:-}"
 if [[ -z "${TARGET_DIR}" ]]; then
     if TARGET_DIR=$(git rev-parse --show-toplevel 2>/dev/null); then
         :
     else
         TARGET_DIR="."
     fi
 fi
 cd "$TARGET_DIR"

KICKOFF_DIR=".asi/kickoff"
PLAN_DIR=".asi/plan"
KICKOFF_FILE="$KICKOFF_DIR/KICKOFF.md"
SKILL_TYPE_FILE="$KICKOFF_DIR/SKILL_TYPE.json"
SCAFFOLD_FILE="$KICKOFF_DIR/SCAFFOLD.json"
PLAN_FILE="$PLAN_DIR/PLAN.md"
TODO_FILE="$PLAN_DIR/TODO.md"
PARSED_FILE="$PLAN_DIR/KICKOFF_PARSED.json"
STATE_FILE="$PLAN_DIR/STATE.json"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--force]

Arguments:
  --force  Overwrite existing plan artifacts if they exist.

This script:
  1. Validates prerequisites (KICKOFF.md approved, artifacts exist)
  2. Parses all kickoff artifacts into structured JSON
  3. Creates .asi/plan/ directory
  4. Populates PLAN.md and TODO.md templates with known values
  5. Computes source_kickoff_hash for drift detection
  6. Creates STATE.json to track procedure progress
  7. Emits receipt to stdout

Exit codes:
  0  Initialization complete
  1  Initialization failed (prerequisites not met)
  2  Invalid arguments
EOF
    exit 2
}

# Helper: portable sha256 hash
sha256_file() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
        return 0
    fi
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
        return 0
    fi
    if command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$file" | awk '{print $NF}'
        return 0
    fi
    echo "ERROR: No sha256 tool found (need sha256sum, shasum, or openssl)" >&2
    return 1
}

# Helper: parse frontmatter field (strips surrounding quotes)
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    local value
    value=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//")
    # Strip surrounding quotes if present
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    echo "$value"
}

# Helper: extract markdown section content
get_section_content() {
    local file="$1"
    local section="$2"
    awk -v section="$section" '
    $0 == "## " section { in_section = 1; next }
    in_section && /^## / { exit }
    in_section { print }
    ' "$file"
}

# Parse arguments
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
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

# Validate prerequisites
echo "=== Validating prerequisites ===" >&2

if [[ ! -d "$KICKOFF_DIR" ]]; then
    echo "ERROR: $KICKOFF_DIR does not exist." >&2
    echo "Run the kickoff phase first: scripts/kickoff-init.sh --skill-name \"<name>\" --skill-purpose \"<purpose>\"" >&2
    exit 1
fi

if [[ ! -f "$KICKOFF_FILE" ]]; then
    echo "ERROR: $KICKOFF_FILE does not exist." >&2
    echo "Run the kickoff phase first: scripts/kickoff-init.sh --skill-name \"<name>\" --skill-purpose \"<purpose>\"" >&2
    exit 1
fi

KICKOFF_STATUS=$(get_frontmatter_field "$KICKOFF_FILE" "status")
if [[ "$KICKOFF_STATUS" != "approved" ]]; then
    echo "ERROR: KICKOFF.md status is '$KICKOFF_STATUS', expected 'approved'." >&2
    echo "Complete kickoff + approve it first (see scripts/kickoff-approve.sh), then rerun scripts/init.sh." >&2
    exit 1
fi

if [[ ! -f "$SKILL_TYPE_FILE" ]]; then
    echo "ERROR: $SKILL_TYPE_FILE does not exist." >&2
    exit 1
fi

if [[ ! -f "$SCAFFOLD_FILE" ]]; then
    echo "ERROR: $SCAFFOLD_FILE does not exist." >&2
    exit 1
fi

echo "Prerequisites validated." >&2

# Check if plan already exists
if [[ -d "$PLAN_DIR" && "$FORCE" != true ]]; then
    echo "ERROR: $PLAN_DIR already exists. Use --force to reinitialize." >&2
    exit 1
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Compute kickoff hash for drift detection
KICKOFF_HASH=$(sha256_file "$KICKOFF_FILE")

# Extract skill name from kickoff
SKILL_NAME=$(get_frontmatter_field "$KICKOFF_FILE" "skill_name")
SKILL_PURPOSE=$(get_frontmatter_field "$KICKOFF_FILE" "skill_purpose")

# Create plan directory
mkdir -p "$PLAN_DIR"

# Parse kickoff artifacts into structured JSON
echo "=== Parsing kickoff artifacts ===" >&2

if command -v jq &>/dev/null; then
    # Parse SKILL_TYPE.json
    SKILL_TYPE=$(jq -r '.type // "unknown"' "$SKILL_TYPE_FILE")
    SKILL_TYPE_REASONING=$(jq -r '.reasoning // ""' "$SKILL_TYPE_FILE")
    
    # Parse SCAFFOLD.json
    SCAFFOLD_CONTENT=$(cat "$SCAFFOLD_FILE")
else
    echo "WARN: jq not available, using basic parsing" >&2
    echo "INFO: Run scripts/bootstrap.sh --check for install guidance (required for full asi-plan flow)." >&2
    SKILL_TYPE="unknown"
    SKILL_TYPE_REASONING=""
    SCAFFOLD_CONTENT="{}"
fi

# Extract kickoff sections
PURPOSE_CONTENT=$(get_section_content "$KICKOFF_FILE" "Purpose")
DETERMINISTIC_CONTENT=$(get_section_content "$KICKOFF_FILE" "Deterministic Surface")
JUDGMENT_CONTENT=$(get_section_content "$KICKOFF_FILE" "Judgment Remainder")
SCHEMA_CONTENT=$(get_section_content "$KICKOFF_FILE" "Schema Designs")
QUESTIONS_CONTENT=$(get_section_content "$KICKOFF_FILE" "Open Questions")

# Create KICKOFF_PARSED.json
cat > "$PARSED_FILE" << EOF
{
  "source": {
    "kickoff_path": "$KICKOFF_FILE",
    "kickoff_hash": "$KICKOFF_HASH",
    "skill_type_path": "$SKILL_TYPE_FILE",
    "scaffold_path": "$SCAFFOLD_FILE",
    "parsed_at": "$TIMESTAMP"
  },
  "skill": {
    "name": "$SKILL_NAME",
    "purpose": "$SKILL_PURPOSE",
    "type": "$SKILL_TYPE",
    "type_reasoning": "$SKILL_TYPE_REASONING"
  },
  "scaffold": $SCAFFOLD_CONTENT,
  "sections": {
    "purpose": $(echo "$PURPOSE_CONTENT" | jq -Rs . 2>/dev/null || echo '""'),
    "deterministic_surface": $(echo "$DETERMINISTIC_CONTENT" | jq -Rs . 2>/dev/null || echo '""'),
    "judgment_remainder": $(echo "$JUDGMENT_CONTENT" | jq -Rs . 2>/dev/null || echo '""'),
    "schema_designs": $(echo "$SCHEMA_CONTENT" | jq -Rs . 2>/dev/null || echo '""'),
    "open_questions": $(echo "$QUESTIONS_CONTENT" | jq -Rs . 2>/dev/null || echo '""')
  }
}
EOF

echo "Created $PARSED_FILE" >&2

# Create PLAN.md with known values
cat > "$PLAN_FILE" << EOF
---
description: "Implementation plan for ${SKILL_NAME}"
timestamp: "${TIMESTAMP}"
status: draft
source_kickoff: "${KICKOFF_FILE}"
source_kickoff_hash: "${KICKOFF_HASH}"
skill_name: "${SKILL_NAME}"
step: 0
---

# Plan: ${SKILL_NAME}

## Scripts

<!-- AGENT: Fill from KICKOFF_PARSED.json deterministic_surface -->

| Script | Purpose | Inputs | Outputs |
| ------ | ------- | ------ | ------- |
|        |         |        |         |

---

## Assets

### Schemas

<!-- AGENT: Fill from KICKOFF_PARSED.json schema_designs -->

| Schema | Purpose |
| ------ | ------- |
|        |         |

### Templates

<!-- AGENT: Fill from KICKOFF_PARSED.json -->

| Template | Purpose |
| -------- | ------- |
|          |         |

---

## Validation

<!-- AGENT: Fill from KICKOFF_PARSED.json deterministic_surface -->

| Mechanism | What it validates | Failure behavior |
| --------- | ----------------- | ---------------- |
|           |                   |                  |

---

## Boundaries

### In scope

<!-- AGENT: Fill from KICKOFF_PARSED.json purpose -->

### Out of scope

<!-- AGENT: Fill from KICKOFF_PARSED.json purpose (non-goals) -->

---

## Non-goals

<!-- AGENT: Fill from KICKOFF_PARSED.json purpose -->

---

## Risks

<!-- AGENT: Fill from KICKOFF_PARSED.json judgment_remainder -->

| Risk | Severity | Mitigation |
| ---- | -------- | ---------- |
|      |          |            |

---

## Lifecycle

### Artifacts produced

<!-- AGENT: Fill this section -->

### Status flow

<!-- AGENT: Fill this section -->

### Human gates

<!-- AGENT: Fill this section -->

EOF

echo "Created $PLAN_FILE" >&2

# Create TODO.md with known values
cat > "$TODO_FILE" << EOF
---
description: "Task list for ${SKILL_NAME}"
timestamp: "${TIMESTAMP}"
status: draft
source_plan: "${PLAN_FILE}"
source_plan_hash: ""
source_kickoff: "${KICKOFF_FILE}"
source_kickoff_hash: "${KICKOFF_HASH}"
step: 0
---

# TODO: ${SKILL_NAME}

## Tasks

<!-- AGENT: Fill from scaffold + PLAN.md sections -->
<!-- Run scripts/generate-tasks.sh first for scaffold-derived tasks -->

| ID   | Description | Status  | Depends On | Source Section |
| ---- | ----------- | ------- | ---------- | -------------- |
|      |             |         |            |                |

---

## Legend

- **Status**: \`pending\` | \`in_progress\` | \`done\`
- **Depends On**: Task IDs that must complete first
- **Source Section**: KICKOFF.md section this task traces to

EOF

echo "Created $TODO_FILE" >&2

# Create STATE.json to track procedure progress
cat > "$STATE_FILE" << EOF
{
  "skill_name": "${SKILL_NAME}",
  "source_kickoff": "${KICKOFF_FILE}",
  "source_kickoff_hash": "${KICKOFF_HASH}",
  "initialized_at": "${TIMESTAMP}",
  "current_step": 0,
  "steps": {
    "0": { "name": "init", "status": "complete", "completed_at": "${TIMESTAMP}" },
    "1": { "name": "generate_scaffold_tasks", "status": "pending", "completed_at": null },
    "2": { "name": "plan_scripts", "status": "pending", "completed_at": null },
    "3": { "name": "plan_assets", "status": "pending", "completed_at": null },
    "4": { "name": "plan_validation", "status": "pending", "completed_at": null },
    "5": { "name": "plan_boundaries", "status": "pending", "completed_at": null },
    "6": { "name": "plan_risks", "status": "pending", "completed_at": null },
    "7": { "name": "plan_lifecycle", "status": "pending", "completed_at": null },
    "8": { "name": "finalize_todo", "status": "pending", "completed_at": null }
  }
}
EOF

echo "Created $STATE_FILE" >&2

# Emit receipt
cat << EOF
{
  "action": "asi-plan-init",
  "status": "complete",
  "timestamp": "$TIMESTAMP",
  "skill_name": "$SKILL_NAME",
  "source_kickoff": "$KICKOFF_FILE",
  "source_kickoff_hash": "$KICKOFF_HASH",
  "created": [
    "$PARSED_FILE",
    "$PLAN_FILE",
    "$TODO_FILE",
    "$STATE_FILE"
  ],
  "next_step": 1,
  "next_action": "Run scripts/generate-tasks.sh to create scaffold-derived tasks, then fill PLAN.md sections"
}
EOF
