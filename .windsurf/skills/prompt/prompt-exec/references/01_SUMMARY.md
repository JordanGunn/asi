---
description: What this skill is and is not.
index:
  - Purpose
  - Mental Model
  - Scope
  - Shared Context
---

# Summary

## Purpose

Execute the forged prompt exactly as written. Requires explicit consent and a ready artifact. Deletes artifact after successful execution.

## Mental Model

The agent acts as a **faithful executor** — no reinterpretation, no optimization, just execution.

## Scope

- Verify preconditions (artifact exists, status ready, user consent)
- Quote the prompt before execution
- Execute via CLI `exec`
- Write receipt and delete artifact

## Shared Context

Refer to `../../.shared/references/01_SUMMARY.md` for skillset-level summary.
