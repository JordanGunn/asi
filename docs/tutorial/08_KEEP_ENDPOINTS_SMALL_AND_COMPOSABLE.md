# Keep Endpoints Small and Composable

## Goal

- prevent endpoint sprawl while preserving capability growth.

## Why This Matters

- endpoint minimization reduces agent misrouting and recovery cost.
- composability through parameters is more stable than command proliferation.

## What To Do

- extend deterministic internals before adding public endpoints.
- require explicit lifecycle and auditability rationale for any new endpoint.
- preserve parity and validation semantics across wrappers.

## What To Avoid

- convenience aliases for existing behavior.
- endpoint additions that leak implementation internals.
- endpoints that bypass validation or reasoning contract constraints.

## Governance Tie-In

This step protects skill interface surface durability and constrains long-term governance entropy.

## Normative References

- `docs/design/principles/11_INTERFACES.md`
- `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`
- `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`
- `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`

## Checkpoint

- Evidence required: decision note for one proposed endpoint (`accept` or `reject`) with criteria evaluation.
- Pass condition: decision is justified by existing surface limits, lifecycle semantics, and parity constraints.
- Common failure signal: endpoint is accepted without proving why `run` + schema cannot represent the behavior.
