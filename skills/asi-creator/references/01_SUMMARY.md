---
description: Identity and scope of asi-creator.
index:
  - Identity
  - Scope
  - Constraints
---

# Summary

## Identity

`asi-creator` is the ASI skill that creates other skills under deterministic governance. It is not a general project planner or coding assistant.

## Scope

It performs:

- interactive decision loop (`next -> suggest -> apply`)
- deterministic session-state persistence and receipts
- skill creation under explicit user-confirmed decisions

## Constraints

- Deterministic validation before state mutation
- Explicit user confirmation for decisions
- CLI-owned schema emission and validation
- Session artifacts are canonical under `.asi/creator/`
