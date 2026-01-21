# 11. Design Operations to Be Idempotent and Lifecycle-Aware

Agent-facing operations should be safe to repeat and explicit about state transitions.

- Re-running the same operation with the same inputs should not destroy valid state, reset progress silently, or create ambiguous duplicates.
- If operations produce artifacts, they should detect existing state and reconcile it intentionally.

Idempotency is not “do nothing twice”; it is “do the right thing twice”.

## Why this matters for ASI

Replayable, lifecycle-aware operations support auditability and reduce hidden state. They also make failures safer by enabling deterministic retry paths (`docs/spec/rfc-001/.INDEX.md`).
