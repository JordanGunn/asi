---
description: How to compile user intent into deterministic CLI parameters.
index:
  - Compilation
  - Guardrails
---

# Intent

## Compilation

`/asi-creator <prompt>` is treated as intent. The agent compiles it into a plan matching the CLI schema.

**Source of truth:** `asi creator --schema`

## Guardrails

- This skill is for ASI skill creation only. Reject generic project planning.
- All decisions must be explicit or confirmed by the user.
- Use the interactive decision loop for open questions.
- Plan and execution phases are gated by explicit approval.
