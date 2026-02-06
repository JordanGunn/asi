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
    - .asi/creator/state.json
    - .asi/creator/ask_sets/*.json
    - .asi/creator/decisions.log.jsonl
    - .asi/creator/receipts/*.json
  keywords:
    - creator
    - skill
    - asi
---

# INSTRUCTIONS

1. Run `./scripts/skill.sh init` and follow the instructions.
