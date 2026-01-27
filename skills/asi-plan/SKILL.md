---
name: asi-plan
license: MIT
description: >
  Unified kickoff + planning entrypoint. If KICKOFF.md is missing or not yet approved,
  this skill guides creation/refinement of kickoff artifacts. Once the kickoff is approved,
  it produces PLAN.md + TODO.md without implementation.
metadata:
  author: Jordan Godau
  version: 0.3.0
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
    - scripts/bootstrap.sh
    - scripts/bootstrap.ps1
    - scripts/kickoff-bootstrap.sh
    - scripts/kickoff-bootstrap.ps1
    - scripts/kickoff-init.sh
    - scripts/kickoff-init.ps1
    - scripts/kickoff-inject.sh
    - scripts/kickoff-inject.ps1
    - scripts/kickoff-checkpoint.sh
    - scripts/kickoff-checkpoint.ps1
    - scripts/kickoff-approve.sh
    - scripts/kickoff-approve.ps1
    - scripts/kickoff-validate.sh
    - scripts/kickoff-validate.ps1
    - scripts/init.sh
    - scripts/init.ps1
    - scripts/generate-tasks.sh
    - scripts/generate-tasks.ps1
    - scripts/inject.sh
    - scripts/inject.ps1
    - scripts/checkpoint.sh
    - scripts/checkpoint.ps1
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

1. Refer to `metadata.references` for the procedure.
