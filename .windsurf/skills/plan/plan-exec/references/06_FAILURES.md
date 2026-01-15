---
description: What to do when things go wrong.
index:
  - Missing or invalid plan
  - Placeholder Work
  - Commands not runnable
---

# Failures

## Missing or invalid plan

- Stop and ask for the correct plan number `<N>`.
- Re-run `../.shared/scripts/skill.sh list` / `../.shared/scripts/skill.sh status <N>`.

## Placeholder Work

- Stop and ask the user to refine Focus/Inputs/Work, or switch back to `plan-create`.

## Commands not runnable

- Stop and instruct user to install `uv`, then re-run `../.shared/scripts/skill.sh validate`.
