---
description: Canonical execution path for this skill.
index:
  - Step 1: Identify target plan
  - Step 2: Load task files
  - Step 3: Execute work
  - Step 4: Record results
  - Additional reference
---

# Procedure

## Step 1: Identify target plan

Use the status command to locate the plan and next active task:

```bash
../.shared/scripts/skill.sh status <N>
```

## Step 2: Load task files

Read:

- `.plan/<N>/plan.md`
- `.plan/<N>/<letter>/index.md`
- `.plan/<N>/<letter>/<roman>.md`

## Step 3: Execute work

- Set task status to `in_progress`.
- Perform each Work step.
- Verify artifacts exist.

## Step 4: Record results

- Write concrete **Output**.
- Write explicit **Handoff**.
- Set task status to `complete`.

## Additional reference

- See `09_PROCEDURE.md` for legacy detail.
