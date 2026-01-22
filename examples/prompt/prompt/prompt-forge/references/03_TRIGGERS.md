---
description: When to invoke or exit this skill.
index:
  - When to Activate
  - When to Exit
---

# Triggers

## When to Activate

- The user explicitly invokes `prompt-forge`
- The user is still clarifying intent and wants a stable on-disk prompt artifact
- There is no active artifact and the user wants to start one

## When to Exit

- The user explicitly switches to `prompt-compile` or `prompt-exec`
- The user explicitly cancels or abandons the prompt
