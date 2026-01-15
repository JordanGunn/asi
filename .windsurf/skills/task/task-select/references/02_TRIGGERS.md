---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- The user asks to switch the active task.
- You need to set `.tasks/.active` deterministically.

## Do not invoke when

- The user is asking to create, list, or close tasks.

## Exit immediately if

- The requested task ID does not exist and the user won’t choose a valid one.
