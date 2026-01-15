---
description: Canonical execution path for this skill.
index:
  - Step 1: Run status
  - Step 2: Report
  - Additional reference
---

# Procedure

## Step 1: Run status

From `skills/plan/plan-status/`, run:

```bash
../.shared/scripts/skill.sh status <N>
```

If `<N>` is omitted, the CLI may default to the latest plan.

## Step 2: Report

- Summarize tasks by state.
- Identify any `in_progress` task.

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
