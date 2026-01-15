---
description: When to invoke or exit this skill.
index:
  - When to Activate
  - When to Exit
  - Shared Context
---

# Triggers

## When to Activate

- User invokes `/prompt-compile`
- User asks to "compile the prompt"
- Artifact exists with `status: ready`
- User wants to generate PROMPT.md

## When to Exit

- PROMPT.md generated and polished
- User explicitly cancels
- No valid artifact exists

## Shared Context

Refer to `../../.shared/references/02_TRIGGERS.md` for skillset-level triggers.
