---
name: asi-exec
license: MIT
description: >
  Execute tasks from approved PLAN.md with controlled implementation.
  This is the only skill authorized to perform implementation.
metadata:
  author: Jordan Godau
  version: 0.1.0
  references:
    - references/00_ROUTER.md
    - references/01_SUMMARY.md
    - references/02_CONTRACTS.md
    - references/03_TRIGGERS.md
    - references/04_NEVER.md
    - references/05_ALWAYS.md
    - references/06_PROCEDURE.md
    - references/07_FAILURES.md
  scripts:
    - scripts/validate.sh
    - scripts/validate.ps1
  assets:
    - assets/schemas/exec_intent_v1.schema.json
    - assets/schemas/exec_receipt_v1.schema.json
    - assets/templates/RECEIPT.template.md
    - assets/templates/QUESTIONS.template.md
  artifacts:
    - RECEIPT.md
    - QUESTIONS.md
    - (implementation files as defined in PLAN.md)
  keywords:
    - exec
    - execute
    - implement
    - build
    - asi
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
