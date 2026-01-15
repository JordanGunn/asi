---
name: prompt-exec
license: MIT
description: >
  Execute the forged prompt exactly as written. Requires explicit consent
  and a ready artifact. Deletes artifact after successful execution.
metadata:
  author: Jordan Godau
  version: 0.1.0
  references:
    - 00_ROUTER.md
    - 01_SUMMARY.md
    - 02_TRIGGERS.md
    - 03_ALWAYS.md
    - 04_NEVER.md
    - 05_PROCEDURE.md
    - 06_FAILURES.md
  scripts:
    - ../.shared/scripts/skill.sh
    - ../.shared/scripts/skill.ps1
  artifacts:
    - .prompt/receipts/
  keywords:
    - prompt
    - execute
    - run
    - proceed
    - go
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
2. Use CLI at `../.shared/scripts/skill.sh` for deterministic operations.
