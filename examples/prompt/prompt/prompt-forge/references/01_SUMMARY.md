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

Shape, refine, and stabilize human intent into a canonical prompt artifact at `.prompt/active.yaml`.

## Mental Model

The agent acts as a collaborative editor: it helps clarify intent and persist it to disk without executing anything.

## Scope

- Maintain a single prompt artifact at `.prompt/active.yaml`
- Record intent fields (objective, constraints, assumptions, open questions)
- Maintain prompt text and status (`drafting` or `ready`)
- Keep all state changes explicit and auditable

## Non-Goals

- Executing prompts
- Compiling prompts into markdown
- Maintaining multiple concurrent prompt artifacts
