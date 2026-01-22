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

Compile `.prompt/active.yaml` into a human-readable markdown artifact at `.prompt/PROMPT.md`.

## Mental Model

The agent acts as a technical writer: it renders structured data into a stable markdown representation.

## Scope

- Generate `.prompt/PROMPT.md` from `.prompt/active.yaml` without mutating the source artifact
- Optionally apply a single subjective polish pass to the generated markdown
- Keep all state changes scoped to `.prompt/`

## Non-Goals

- Modifying `.prompt/active.yaml` intent or prompt text
- Executing prompts
