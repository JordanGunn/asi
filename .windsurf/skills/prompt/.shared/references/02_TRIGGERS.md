---
description: When to invoke or exit this skill.
index:
  - Invoke When
  - Do Not Invoke When
  - Exit Immediately If
  - Do Not Infer
---

# Triggers

When to activate or exit the prompt skillset.

## Invoke When

- User wants to craft a complex prompt
- User needs help refining intent before execution
- User explicitly requests prompt forging
- Work requires separation of design and execution

## Do Not Invoke When

- User has a simple, clear request
- User explicitly says "just do it"
- Prompt is trivial and doesn't need refinement
- User is mid-execution of another task

## Exit Immediately If

- User approves prompt and requests execution
- User abandons the prompt
- User explicitly exits the workflow

## Do Not Infer

- Do not start forging without user confirmation
- Do not assume user wants prompt refinement
- Do not execute prompts without explicit consent
