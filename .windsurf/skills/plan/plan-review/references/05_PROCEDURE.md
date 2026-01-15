---
description: Canonical execution path for this skill.
index:
  - Step 1: Load plan status
  - Step 2: Review tasks
  - Step 3: Review success criteria
  - Step 4: Write assessment
  - Additional reference
---

# Procedure

## Step 1: Load plan status

From `skills/plan/plan-review/`, run:

```bash
../.shared/scripts/skill.sh status <N>
```

## Step 2: Review tasks

- Verify each completed task has concrete Output and explicit Handoff.
- Verify artifacts referenced in Output exist.

## Step 3: Review success criteria

- Read `.plan/<N>/plan.md` success criteria.
- Check each criterion against evidence.

## Step 4: Write assessment

- Append a review section to `.plan/<N>/plan.md`.

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
