---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- The user asks to create a new task.
- Work needs to be tracked as a single bounded task file.

## Do not invoke when

- The user wants to select, list, or close tasks (use the corresponding skill).

## Exit immediately if

- The task ID is not kebab-case and the user won’t provide a valid ID.
