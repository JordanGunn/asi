---
name: plan
license: MIT
description: >
  Agent-optimized planning skill for agentic-supported programming sessions.
  Creates, manages, and tracks structured plans with deterministic state management.
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
    - scripts/init.sh
    - scripts/add-step.sh
    - scripts/update-status.sh
    - scripts/status.sh
    - scripts/archive.sh
    - scripts/validate.sh
  assets:
    - assets/schemas/plan_v1.schema.json
    - assets/schemas/plan_intent_v1.schema.json
    - assets/schemas/plan_result_v1.schema.json
    - assets/templates/active.template.yaml
  artifacts:
    - .plan/active.yaml
    - .plan/active/STATE.json
    - .plan/archive/<timestamp>/
  keywords:
    - plan
    - planning
    - tasks
    - steps
    - state
---

# INSTRUCTIONS

1. Run `scripts/init.sh --name <plan-name>` to create a new plan.
2. Run `scripts/add-step.sh --step "<description>"` to add steps.
3. Run `scripts/status.sh` to view current plan status.
4. Refer to `metadata.references` for full procedure.
