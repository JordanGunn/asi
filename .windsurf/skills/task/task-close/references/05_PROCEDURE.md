---
description: Canonical execution path for this skill.
index:
  - Step 1: Verify readiness
  - Step 2: Close
  - Step 3: Verify
  - Additional reference
---

# Procedure

## Step 1: Verify readiness

- For `completed`: acceptance criteria are checked.
- For `abandoned`: the decision to stop is explicit.

## Step 2: Close

From `skills/task/task-close/`, run:

```bash
../.shared/scripts/skill.sh close <id> --reason completed
```

or:

```bash
../.shared/scripts/skill.sh close <id> --reason abandoned
```

## Step 3: Verify

```bash
../.shared/scripts/skill.sh list --state closed
```

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
