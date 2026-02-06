---
description: Mandatory and prohibited behaviors for asi-creator.
index:
  - Always
  - Never
---

# Policies

## Always

- Always use CLI-emitted schemas and deterministic validation.
- Always ask user confirmation for open questions.
- Always persist canonical session artifacts under `.asi/creator/`.
- Always emit deprecation warnings when legacy kickoff/plan/exec artifacts are detected.

## Never

- Never use this skill as a general project planner.
- Never infer missing requirements without user confirmation.
- Never bypass the interactive decision loop.
- Never treat legacy kickoff/plan/exec artifacts as canonical creator runtime state.
