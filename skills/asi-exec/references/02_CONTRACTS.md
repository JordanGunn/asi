# Reasoning Contracts

## Contract declaration

This skill uses two reasoning contracts and ingests plan artifacts.

1. **Exec Intent Contract** — What execution is requested
2. **Exec Receipt Contract** — What was executed and the outcome

## Input Artifacts (from asi-plan)

The skill reads from `.asi/plan/` and `.asi/kickoff/`:

| Artifact | Location | Purpose |
| -------- | -------- | ------- |
| `PLAN.md` | `.asi/plan/PLAN.md` | Implementation plan, must be `status: approved` |
| `TODO.md` | `.asi/plan/TODO.md` | Task list with status tracking |
| `SCAFFOLD.json` | `.asi/kickoff/SCAFFOLD.json` | Directory structure to create |

## Exec Intent Contract

The agent must derive structured intent from plan artifacts.

**Schema:** `assets/schemas/exec_intent_v1.schema.json`

### Required derivations

| Field | Source | Constraint |
| ----- | ------ | ---------- |
| `plan_path` | Fixed | `.asi/plan/PLAN.md` |
| `todo_path` | Fixed | `.asi/plan/TODO.md` |
| `scaffold_path` | Fixed | `.asi/kickoff/SCAFFOLD.json` |

### Optional derivations

| Field | Source | Default |
| ----- | ------ | ------- |
| `task_filter` | User request | null (next pending task) |
| `dry_run` | User request | false |

### Disallowed derivations

- Do not execute if `.asi/plan/PLAN.md` status is not `approved`
- Do not execute tasks not in `.asi/plan/TODO.md`
- Do not infer tasks from PLAN.md sections directly

## Exec Receipt Contract

After execution, the agent must produce a structured receipt.

**Schema:** `assets/schemas/exec_receipt_v1.schema.json`

### Required fields

| Field | Source | Constraint |
| ----- | ------ | ---------- |
| `task_id` | TODO.md | Must match executed task |
| `status` | Execution outcome | `success`, `failed`, or `skipped` |
| `timestamp` | System | ISO 8601 |

### Optional fields

| Field | Source |
| ----- | ------ |
| `artifacts_created` | Files created during execution |
| `artifacts_modified` | Files modified during execution |
| `error` | Error message if failed |
| `notes` | Observations or context |
