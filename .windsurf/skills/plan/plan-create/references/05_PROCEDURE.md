---
description: Canonical execution path for this skill.
index:
  - Step 1: Surface scan
  - Step 2: Initialize plan
  - Step 3: Populate plan files
  - Step 4: Validate
  - Additional reference
---

# Procedure

## Step 1: Surface scan

From `skills/plan/plan-create/`, run:

```bash
../.shared/scripts/skill.sh surface --patterns "*.py" "*.md" "*.yaml"
```

## Step 2: Initialize plan

```bash
../.shared/scripts/skill.sh init --title "Description of objective"
```

## Step 3: Populate plan files

- Populate `.plan/<N>/plan.md` with objective, success criteria, and sub-plan index.
- Populate each sub-plan `index.md` with task list.
- Populate each task file with Focus, Inputs, and Work.

## Step 4: Validate

```bash
../.shared/scripts/skill.sh status <N>
```

## Additional reference

- See `08_PROCEDURE.md` for legacy detail.
