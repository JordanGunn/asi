---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- A plan exists under `.plan/<N>/` and the user wants execution.
- There are pending/in-progress tasks that must be completed.

## Do not invoke when

- The user wants to create a new plan (use `plan-create`).

## Exit immediately if

- Focus/Inputs/Work are placeholders and the user does not want to refine them.
