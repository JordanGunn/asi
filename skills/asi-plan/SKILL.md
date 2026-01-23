---
name: asi-plan
license: MIT
description: >
  Decompose an approved KICKOFF.md into detailed PLAN.md and TODO.md artifacts.
  This skill bridges high-level design to actionable tasks without implementation.
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
    - scripts/generate-tasks.sh
    - scripts/inject.sh
    - scripts/checkpoint.sh
    - scripts/validate.sh
    - scripts/validate.ps1
  assets:
    - assets/schemas/plan_v1.schema.json
    - assets/schemas/todo_v1.schema.json
    - assets/schemas/step_output_v1.schema.json
    - assets/templates/PLAN.template.md
    - assets/templates/TODO.template.md
  artifacts:
    - .asi/plan/KICKOFF_PARSED.json
    - .asi/plan/tasks_scaffold.json
    - .asi/plan/PLAN.md
    - .asi/plan/TODO.md
    - .asi/plan/STATE.json
    - .asi/plan/step_*_output.json
  keywords:
    - plan
    - decomposition
    - tasks
    - todo
    - asi
---

# INSTRUCTIONS

1. Run `scripts/init.sh` first (validates kickoff, parses artifacts, creates templates).
2. Run `scripts/generate-tasks.sh` to create scaffold-derived tasks.
3. Then refer to `metadata.references` for the procedure.
