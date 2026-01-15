---
description: Canonical execution path for this skill.
index:
  - Step 1: Identify the task
  - Step 2: Select
  - Step 3: Verify
  - Additional reference
---

# Procedure

## Step 1: Identify the task

List tasks:

```bash
../.shared/scripts/skill.sh list
```

## Step 2: Select

From `skills/task/task-select/`, run:

```bash
../.shared/scripts/skill.sh select <id>
```

## Step 3: Verify

```bash
../.shared/scripts/skill.sh list
```

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
