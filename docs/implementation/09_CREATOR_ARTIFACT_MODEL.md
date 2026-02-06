# Creator Artifact Model

This document defines the canonical runtime artifact contract for `asi creator`.

## Status

- Canonical model: active now.
- Legacy kickoff/plan/exec artifacts: supported as a one-release bridge with deprecation warnings.

## Canonical Paths

All canonical creator runtime artifacts live under `.asi/creator/`:

- `state.json`: current mutable session state (decisions, in-flight ask set).
- `ask_sets/<ask_set_id>.json`: immutable snapshots emitted by `suggest`.
- `decisions.log.jsonl`: append-only decision events written during `apply`.
- `receipts/<timestamp>.json`: apply outcome payloads for audit and replay.

## Contract Rules

1. `state.json` is authoritative for current session state.
2. `ask_sets/*.json` are immutable once written.
3. `decisions.log.jsonl` is append-only.
4. `receipts/*.json` are immutable records keyed by timestamped filename.
5. Creator responses should expose artifact pointers when new artifacts are produced.

## Legacy Bridge

Deprecated paths that may still exist:

- `.asi/creator/kickoff/`
- `.asi/creator/plan/`
- `.asi/creator/exec/`
- `.asi/kickoff/`
- `.asi/plan/`
- `.asi/exec/`

Bridge behavior:

1. Creator runtime emits warning code `creator_legacy_artifacts_detected` when legacy paths are found.
2. Legacy paths are not canonical state for interactive loop behavior.
3. Sunset target: next release after introduction of this model.

## Rationale

The interactive creator loop is session-driven (`next -> suggest -> apply`), not phase-driven. Session artifacts reduce conceptual drift between runtime behavior and governance documentation while preserving deterministic evidence for audit and replay.
