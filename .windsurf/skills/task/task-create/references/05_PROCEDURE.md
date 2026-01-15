---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather inputs
  - Step 2: Create
  - Step 3: Verify
  - Additional reference
---

# Procedure

## Step 1: Gather inputs

Determine:

- `id` (kebab-case)
- `title` (optional)
- `kind` (`feature`, `fix`, `refactor`, `docs`, `chore`, `spike`)
- `risk` (`low`, `medium`, `high`)

## Step 2: Create

From `skills/task/task-create/`, run:

```bash
../.shared/scripts/skill.sh create <id> --title "Title" --kind <kind> --risk <risk> --select
```

## Step 3: Verify

```bash
../.shared/scripts/skill.sh list
```

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
