---
name: asi-exec
license: MIT
description: >
  Execute tasks from approved PLAN.md with controlled implementation.
  This is the only skill authorized to perform implementation.
metadata:
  author: Jordan Godau
  version: 0.2.0
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
    - scripts/init.sh
    - scripts/select-task.sh
    - scripts/update-status.sh
    - scripts/append-receipt.sh
    - scripts/checkpoint.sh
    - scripts/validate.sh
    - scripts/validate.ps1
  assets:
    - assets/schemas/exec_intent_v1.schema.json
    - assets/schemas/exec_receipt_v1.schema.json
    - assets/schemas/task_output_v1.schema.json
    - assets/templates/RECEIPT.template.md
  artifacts:
    - .asi/exec/PLAN_PARSED.json
    - .asi/exec/STATE.json
    - .asi/exec/RECEIPT.md
    - .asi/exec/task_*_output.json
    - .asi/exec/task_*_receipt.json
    - (implementation files as defined in .asi/plan/PLAN.md)
  keywords:
    - exec
    - execute
    - implement
    - build
    - asi
---

# INSTRUCTIONS

1. Run `scripts/init.sh` first (validates plan, parses artifacts, creates state).
2. Run `scripts/select-task.sh` to get next task.
3. Then refer to `metadata.references` for the procedure.
