---
description: Identity and scope of asi-onboard.
index:
  - Identity
  - Scope
  - Constraints
---

# Summary

## Identity

`asi-onboard` builds disk-backed context for working in this repository.

## Scope

It is designed for **idempotent, resumable** doc exploration and context capture:

- Creates a scoped context digest in `.asi/onboard/NOTES.md`
- Tracks sources consulted in `.asi/onboard/SOURCES.md`
- Tracks lifecycle state in `.asi/onboard/STATE.json`

## Constraints

This skill is intentionally **not** part of the planning/execution gate:

- Not a kickoff, planning, or execution skill (use `asi-creator`)

Primary outputs:

- `.asi/onboard/NOTES.md`
- `.asi/onboard/SOURCES.md`
