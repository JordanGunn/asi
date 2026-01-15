---
description: Canonical execution path for this skill.
index:
  - Step 1: List tasks
  - Step 2: Filter
  - Step 3: Interpret flags
  - Additional reference
---

# Procedure

## Step 1: List tasks

From `skills/task/task-list/`, run:

```bash
../.shared/scripts/skill.sh list
```

## Step 2: Filter

Examples:

```bash
../.shared/scripts/skill.sh list --state open
../.shared/scripts/skill.sh list --stale
```

## Step 3: Interpret flags

- `*` active
- `stale` task is stale
- `hash-mismatch` task intent has drifted

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
