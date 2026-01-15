---
description: When to invoke or exit this skill.
index:
  - When to Activate
  - When to Exit
  - Shared Context
---

# Triggers

## When to Activate

- User invokes `/prompt-exec`
- User says "execute", "run", "go", "proceed"
- Artifact exists with `status: ready`

## When to Exit

- Prompt executed and artifact deleted
- User explicitly cancels
- Preconditions not met

## Shared Context

Refer to `../../.shared/references/02_TRIGGERS.md` for skillset-level triggers.
