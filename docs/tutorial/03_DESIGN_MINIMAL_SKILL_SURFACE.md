# Design Minimal Skill Interface Surface

## Goal

- define the smallest skill interface surface and wrapper command surface that support robust agent workflows.

## Why This Matters

- smaller public surfaces reduce ambiguity and recovery cost.
- command minimalism improves portability and consistency.

## What To Do

- implement only `help`, `init`, `validate`, `schema`, `run` at the wrapper surface.
- document one clear responsibility per command.
- ensure lifecycle semantics are explicit and non-overlapping.

## What To Avoid

- adding convenience endpoints that duplicate existing behavior.
- bundling unrelated phases into opaque commands.
- adding side effects to read-only commands.

## Governance Tie-In

This step enforces skill interface surface minimization and prevents wrapper command surface entropy.

## Normative References

- `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`
- `docs/design/specs/scripts/01_OVERVIEW.md`
- `docs/design/principles/10_PORTABILITY.md`
- `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`

## Checkpoint

- Evidence required: command contract table with one responsibility and one non-goal per command.
- Pass condition: table contains exactly five commands and no duplicated responsibilities.
- Common failure signal: proposed extra commands are justified only by convenience.
