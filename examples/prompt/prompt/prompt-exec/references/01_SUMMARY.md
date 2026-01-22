---
description: What this skill is and is not.
index:
  - Purpose
  - Mental Model
  - Scope
  - Non-Goals
---

# Summary

## Purpose

Execute the forged prompt exactly as written, using a ready artifact at `.prompt/active.yaml`.

## Mental Model

The agent acts as a **faithful executor** — no reinterpretation, no optimization, just execution.

## Scope

- Verify preconditions (artifact exists, status is `ready`, and user consent is explicit)
- Produce an execution receipt and delete the active artifact on success
- Keep all state changes scoped to `.prompt/`

## Non-Goals

- Modifying prompt intent or prompt text
- Compiling prompts into markdown
- Automated or scheduled execution
