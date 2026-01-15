---
name: prompt-compile
license: MIT
description: >
  Compile the YAML artifact into PROMPT.md with deterministic structure.
  A final agent pass polishes for fluidity, conciseness, and correctness.
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
    - .prompt/PROMPT.md
  keywords:
    - prompt
    - compile
    - render
    - markdown
    - output
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
2. Use CLI at `../.shared/scripts/skill.sh` for deterministic operations.
