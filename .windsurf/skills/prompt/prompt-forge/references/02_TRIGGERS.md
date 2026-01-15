---
description: When to invoke or exit this skill.
index:
  - When to Activate
  - When to Exit
  - Shared Context
---

# Triggers

## When to Activate

- User invokes `/prompt-forge` or mentions "forge a prompt"
- User wants to clarify intent before execution
- User needs help articulating a complex request
- No active prompt exists and user wants to create one

## When to Exit

- Artifact marked `status: ready`
- User explicitly cancels or abandons
- User switches to a different skill

## Shared Context

Refer to `../../.shared/references/02_TRIGGERS.md` for skillset-level triggers.
