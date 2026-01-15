---
name: prompt-forge
license: MIT
description: >
  Shape, refine, and stabilize human intent into a canonical prompt artifact.
  Iteratively clarifies ambiguity until user confirms readiness.
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
    - .prompt/active.yaml
  keywords:
    - prompt
    - forge
    - refine
    - clarify
    - intent
    - draft
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
2. Use CLI at `../.shared/scripts/skill.sh` for deterministic operations.
