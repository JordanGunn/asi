---
name: asi-creator
license: MIT
description: >
  Create ASI-compliant skills with deterministic governance. This is not a general
  project planning tool; it is a skill creation workflow with explicit gates.
metadata:
  author: Jordan Godau
  version: 0.1.0
  references:
    - references/01_SUMMARY.md
    - references/02_INTENT.md
    - references/03_POLICIES.md
    - references/04_PROCEDURE.md
  scripts:
    - scripts/skill.sh
    - scripts/skill.ps1
  artifacts:
    - .asi/creator/kickoff/KICKOFF.md
    - .asi/creator/plan/PLAN.md
    - .asi/creator/plan/TODO.md
    - .asi/creator/exec/RECEIPT.md
  keywords:
    - creator
    - skill
    - asi
---

# INSTRUCTIONS

1. Run `./scripts/skill.sh init` and follow the instructions.
