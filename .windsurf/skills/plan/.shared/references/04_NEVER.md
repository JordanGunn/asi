---
description: Forbidden behaviors for this skill.
index:
  - No False Completion
  - No Scope Creep
  - No Hidden State
  - No Premature Action
---

# Never

Forbidden behaviors for the plan skillset.

## No False Completion

- Never mark a task complete without performing the Work
- Never fill Output with descriptions instead of results
- Never skip verification of produced artifacts

## No Scope Creep

- Never work ahead on later sub-plans
- Never expand scope without user consent
- Never modify completed task files

## No Hidden State

- Never rely on conversation memory alone
- Never assume plan state without checking disk
- Never produce artifacts outside `.plan/`

## No Premature Action

- Never skip plan-create and jump to execution
- Never execute malformed plans (placeholder content)
- Never skip the wrap-up phase
