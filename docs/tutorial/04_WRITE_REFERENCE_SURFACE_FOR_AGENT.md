# Write Canonical References for the Skill Interface Surface

## Goal

- create the agent-facing reference surface using canonical files and focused content.

## Why This Matters

- canonical references reduce context waste and improve deterministic onboarding.
- separation of summary/intent/policies/procedure prevents instruction overlap.

## What To Do

- use canonical files: `01_SUMMARY.md`, `02_INTENT.md`, `03_POLICIES.md`, `04_PROCEDURE.md`.
- include `00_ROUTER.md` only if deterministic branching is required.
- keep each file scoped to one role.

## What To Avoid

- mixing policy and procedure within the same section.
- splitting references into many micro-docs without deterministic need.
- embedding speculative design notes in canonical reference files.

## Governance Tie-In

This step protects deterministic scope loading and traceable reference ownership.

## Normative References

- `docs/design/specs/references/05_CANON.md`
- `docs/design/specs/references/files/01_SUMMARY.md`
- `docs/design/specs/references/files/02_INTENT.md`
- `docs/design/specs/references/files/03_POLICIES.md`
- `docs/design/specs/references/files/04_PROCEDURE.md`
- `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`

## Checkpoint

- Evidence required: one-page file-purpose map for all reference files and optional router decision note.
- Pass condition: each file has a unique purpose and router usage is explicitly justified or rejected.
- Common failure signal: overlapping content between `03_POLICIES` and `04_PROCEDURE`.
