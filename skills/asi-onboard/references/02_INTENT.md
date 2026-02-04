---
description: How to compile user intent into deterministic onboarding parameters.
index:
  - Invocation Intent
  - Derived Parameters
  - Output Contract
  - Judgment Surface
---

# Intent

`asi-onboard` converts a user’s onboarding goal into deterministic steps for reading documentation and capturing a scoped context digest.

## Invocation Intent

Use `asi-onboard` when you need disk-backed context before planning or execution. Do not use it for kickoff, planning, or implementation.

## Derived Parameters

The primary derived parameter is a short topic string used to scope onboarding output. It must be explicit, short, and user-aligned.

Schema pointer: `asi onboard --schema`.

## Output Contract

The skill maintains three artifacts:

- `.asi/onboard/NOTES.md` for a concise context digest.
- `.asi/onboard/SOURCES.md` for a list of consulted sources and rationale.
- `.asi/onboard/STATE.json` for idempotent lifecycle state.

## Judgment Surface

Judgment is limited to selecting what to read next based on the user’s goal and extracting constraints and invariants into the notes. This must remain auditable in step outputs.
