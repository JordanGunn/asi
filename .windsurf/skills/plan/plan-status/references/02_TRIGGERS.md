---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- The user asks for plan progress/status.
- You need to identify the next task to work.

## Do not invoke when

- The user wants to create a new plan (use `plan-create`).

## Exit immediately if

- No `.plan/` directory exists and the user does not want to create one.
