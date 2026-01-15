---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the task skillset.

## Common Failure Cases

### No Tasks Exist

When `./skill.sh list` shows empty:

1. Create a task with `./skill.sh create`
2. Or confirm user doesn't need tracking

### No Active Task

When attempting to close with no selection:

1. Run `./skill.sh list` to see available tasks
2. Select one with `./skill.sh select <id>`
3. Then close when ready

### Task Already Active

When selecting while another is active:

1. Close or deselect current task first
2. Then select the new one

## When to Abort

- User explicitly abandons task tracking
- User switches to different workflow
- Task is no longer relevant

## When to Continue

- Task taking longer than expected is normal
- Switching between tasks is acceptable
- Partial progress is valid
