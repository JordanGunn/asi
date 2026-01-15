---
description: Canonical execution path for this skill.
index:
  - Commands
  - Typical Flow
  - Artifact Structure
---

# Procedure

CLI commands for the prompt skillset.

## Commands

```bash
./skill.sh help              # Show help
./skill.sh validate          # Check runnable
./skill.sh status            # Show artifact status
./skill.sh init              # Create new prompt artifact
./skill.sh show              # Display current artifact
./skill.sh ready             # Mark artifact as ready
./skill.sh compile           # Compile YAML to markdown
./skill.sh exec              # Execute the prompt
./skill.sh receipts          # List execution receipts
./skill.sh clean             # Remove artifacts
```

## Typical Flow

1. `./skill.sh init` — Create artifact
2. Use prompt-forge to refine content
3. `./skill.sh ready` — Mark as ready
4. `./skill.sh compile` — Generate PROMPT.md
5. `./skill.sh exec` — Execute with consent
6. `./skill.sh receipts` — View history

## Artifact Structure

```text
.prompt/
├── active.yaml      # Current prompt artifact
├── PROMPT.md        # Compiled markdown
└── receipts/        # Execution receipts
    └── <hash>.yaml
```
