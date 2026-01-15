---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- You need to create a new structured plan under `.plan/<N>/`.
- The user requests a plan scaffold with tasks.

## Do not invoke when

- A plan already exists and the user only wants execution (use `plan-exec`).

## Exit immediately if

- The target scope is unclear and the user cannot specify a bounded objective.
