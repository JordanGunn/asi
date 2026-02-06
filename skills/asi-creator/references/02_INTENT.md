---
description: How to compile user intent into deterministic CLI parameters.
index:
  - Compilation
  - Guardrails
---

# Intent

## Compilation

`/asi-creator <prompt>` is treated as intent. The agent compiles it into a creator run request matching the CLI schema.

**Source of truth:** `asi creator --schema`

## Guardrails

- This skill is for ASI skill creation only. Reject generic project planning.
- All decisions must be explicit or confirmed by the user.
- Use the interactive decision loop for open questions.
- Persist decision and receipt evidence in canonical session artifacts.
