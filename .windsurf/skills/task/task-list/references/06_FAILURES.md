---
description: What to do when things go wrong.
index:
  - No tasks found
  - CLI not runnable
---

# Failures

## No tasks found

- Report that `.tasks/` is missing or empty.
- Suggest `task-create` to create a task.

## CLI not runnable

- Instruct the user to install `uv`.
- Re-run `../.shared/scripts/skill.sh validate`.
