# Tutorial Scope and Mental Model

## Goal

- establish what this tutorial is optimizing: deterministic skill behavior with constrained agent judgment.

## Why This Matters

- agents fail when they infer too much from ambiguous or oversized skill interface surfaces.
- ASI reduces entropy before reasoning to improve reliability and auditability.

## What To Do

- define deterministic and judgmental responsibilities before drafting interfaces.
- keep the skill interface surface focused on agent capabilities, not internal mechanisms.
- treat deterministic reduction as the required first phase.

## What To Avoid

- writing skill docs that blur deterministic and judgment boundaries.
- exposing implementation internals as agent-facing capabilities.
- treating reasoning as a replacement for reasoning contract design.

## Governance Tie-In

This step protects boundary correctness and prevents early scope drift at design time.

## Normative References

- `docs/design/model/04_BOUNDARIES.md`
- `docs/design/principles/01_DETERMINISTIC_MAXIMILISM.md`
- `docs/design/principles/11_INTERFACES.md`
- `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`

## Checkpoint

- Evidence required: one-paragraph boundary statement plus a two-row table (`deterministic task`, `judgment task`).
- Pass condition: statement explicitly says deterministic reduction happens before reasoning and examples are correctly classified.
- Common failure signal: tasks are classified by convenience instead of determinism vs ambiguity.
