# Build Procedure with Checkpoints

## Goal

- design a grep-skill procedure that is executable, diagnosable, and easy to review.

## Why This Matters

- deterministic checkpoints make behavior inspectable and failures actionable.
- explicit step artifacts prevent hidden state transitions.

## What To Do

- define sequence: intent -> parameters -> run -> results -> refinement.
- define expected artifact at each step.
- define corrective actions for empty, over-broad, and invalid outcomes.

## What To Avoid

- procedural steps without expected artifacts.
- vague failure states with no deterministic next action.
- refinement rules that bypass the reasoning contract declared by help/schema.

## Governance Tie-In

This step protects auditability and repeatability across skill runs and reviews.

## Normative References

- `docs/design/specs/references/files/04_PROCEDURE.md`
- `docs/design/specs/references/files/02_INTENT.md`
- `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md`

## Checkpoint

- Evidence required: five-step artifact map with failure-mode correction matrix.
- Pass condition: each failure mode maps to one deterministic corrective action.
- Common failure signal: correction actions are qualitative suggestions without parameter-level changes.
