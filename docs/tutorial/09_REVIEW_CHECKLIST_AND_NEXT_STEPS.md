# Review Checklist and Next Steps

## Goal

- define completion criteria for a tutorial-built grep-style skill interface surface.

## Why This Matters

- explicit completion gates prevent “looks done” outcomes that are not auditable.
- standardized evidence packages improve reviewer consistency.

## What To Do

- run the completion checklist and collect required evidence.
- verify deterministic/judgment boundary integrity.
- verify help/schema-driven correction and small-surface discipline.

## What To Avoid

- marking completion without evidence artifacts.
- accepting endpoint growth without composability justification.
- treating empirical observations as normative requirements.

## Governance Tie-In

This step ties tutorial outputs to compliance review, claim confidence, and measurement discipline.

## Normative References

- `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md`
- `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`
- `docs/implementation/08_MEASUREMENT_PROTOCOL.md`

## Checkpoint

- Evidence required: completed checklist, evidence package, and one-page self-audit summary.
- Pass condition: all completion checks are satisfied and evidence artifacts are present and traceable.
- Common failure signal: checklist marked complete while required outputs are missing.

Completion checklist:

- [ ] wrapper command surface contains only `help`, `init`, `validate`, `schema`, `run`.
- [ ] references follow canonical file set and clear separation of concerns.
- [ ] `help` supports correction-oriented retries.
- [ ] `schema` acts as source-of-truth reasoning contract for plan shape.
- [ ] procedure includes explicit checkpoints and failure handling.
- [ ] endpoint additions are justified by boundary/composability criteria.

Review evidence package:

- wrapper help outputs (both shell and PowerShell).
- sample init output showing deterministic reference loading.
- schema output sample.
- sample run output summary and refinement pass.
- reference file listing and purpose mapping.

Suggested next steps:

- apply the same tutorial method to a second skill (for example `find` or `ls`).
- add router semantics only if lifecycle branching is required.
- add measurement artifacts following `docs/implementation/08_MEASUREMENT_PROTOCOL.md`.
