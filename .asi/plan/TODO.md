---
description: "Task list for plan"
timestamp: "2026-01-23T20:37:35Z"
status: approved
source_plan: ".asi/plan/PLAN.md"
source_plan_hash: 2d9b07f0680b431670517600900df75030cac0d5cf504f85cb74aabdb79340df
source_kickoff: ".asi/kickoff/KICKOFF.md"
source_kickoff_hash: "61e8171332b2ffef6ad14372d2331c808a54d2a7be99e05d0f601fdbb11cfbe1"
step: 0
---

# TODO: plan

## Tasks

| ID   | Description | Status  | Depends On | Source Section |
| ---- | ----------- | ------- | ---------- | -------------- |
| T001 | Create skill directory structure: skills/plan/{scripts,assets,references} | done | - | SCAFFOLD |
| T002 | Create SKILL.md manifest with metadata and references | done | T001 | SCAFFOLD |
| T003 | Create assets/schemas/plan_v1.schema.json | done | T001 | Schema Designs |
| T004 | Create assets/schemas/plan_intent_v1.schema.json | done | T001 | Schema Designs |
| T005 | Create assets/schemas/plan_result_v1.schema.json | done | T001 | Schema Designs |
| T006 | Create assets/templates/active.template.yaml | done | T003 | Assets |
| T007 | Create scripts/init.sh for plan creation | done | T003, T006 | Scripts |
| T008 | Create scripts/add-step.sh for adding steps | done | T003 | Scripts |
| T009 | Create scripts/update-status.sh for status updates | done | T003 | Scripts |
| T010 | Create scripts/status.sh for plan display | done | T003 | Scripts |
| T011 | Create scripts/archive.sh for plan archival | done | T003 | Scripts |
| T012 | Create scripts/validate.sh for plan validation | done | T003 | Validation |
| T013 | Create references/00_ROUTER.md through 07_FAILURES.md | done | T002 | SCAFFOLD |
| T014 | Create .windsurf/workflows/plan.md workflow file | done | T002 | SCAFFOLD |
| T015 | Validate complete skill with scripts/validate.sh --check all | done | T007, T008, T009, T010, T011, T012, T013 | Validation |

---
## Legend

- **Status**: `pending` | `in_progress` | `done`
- **Depends On**: Task IDs that must complete first
- **Source Section**: KICKOFF.md section this task traces to

