---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the plan skillset.

## Common Failure Cases

### Malformed Plan

When plan contains placeholders in Focus/Inputs/Work:

1. Halt execution
2. Notify user that plan-create did not complete properly
3. Return to plan-create to fill in content

### Stale Session

When resuming after context loss:

1. Run `./skill.sh status <N>`
2. Read the active task file
3. Continue from recorded state

### Scope Expansion

When work reveals larger scope than planned:

1. Document finding in current task Output
2. Complete current task with what's achievable
3. Recommend scope expansion in Handoff
4. Do not expand within current task

## When to Abort

- User explicitly abandons plan
- Plan objective no longer relevant
- Blocking dependency cannot be resolved

## When to Continue

- Partial completion is normal
- Some tasks may need iteration
- User frustration does not mean failure
