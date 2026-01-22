# Reasoning Contracts

## Contract declaration

This skill uses two reasoning contracts:

1. **Exec Intent Contract** — What execution is requested
2. **Exec Receipt Contract** — What was executed and the outcome

## Exec Intent Contract

The agent must derive structured intent from the user's request.

**Schema:** `assets/schemas/exec_intent_v1.schema.json`

### Required derivations

| Field | Source | Constraint |
| ----- | ------ | ---------- |
| `source_plan` | Context or user | Must point to approved PLAN.md |
| `source_todo` | Context or user | Must point to TODO.md |

### Optional derivations

| Field | Source | Default |
| ----- | ------ | ------- |
| `task_filter` | User request | null (next pending task) |
| `dry_run` | User request | false |

### Disallowed derivations

- Do not execute if PLAN.md status is not `approved`
- Do not execute tasks not in TODO.md
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
