# Summary

## What this skill does

`asi-exec` executes tasks from an approved PLAN.md, updating TODO.md progress:

1. **Single-task execution** — One task at a time with explicit status updates
2. **Progress tracking** — `pending` → `in_progress` → `done`
3. **Implementation** — Creates scripts, schemas, assets per PLAN.md

It is the **only skill authorized to perform implementation**.

## What problems it solves

- Prevents uncontrolled implementation
- Ensures traceability (task → PLAN → KICKOFF)
- Enables pause/resume execution
- Creates auditable execution trail
- Enforces single-task focus

## What this skill is NOT

- Not a planning skill (that is `asi-plan`)
- Not a design skill (that is `asi-kickoff`)
- Not autonomous — requires approved artifacts
- Not parallel — single task at a time

## Constraints

- Requires approved PLAN.md
- Requires TODO.md with tasks
- Drift detection before execution
- Single-task granularity
- Status updates are atomic

## Invocation shape

**Primary prompt:**

> "Execute the next task for [skill-name]"

**Explicit scope inputs:**

- Source PLAN.md path (required, must be approved)
- TODO.md path (required)
- Task filter (optional, specific task ID)
- Dry run flag (optional, report without executing)
