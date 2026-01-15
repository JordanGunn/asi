# 05_PROCEDURE.md — The canonical execution path

**Purpose**:

* Define *how* the skill is executed, step by step
* Serve as the default path unless explicitly overridden

**Contains**:

* Ordered steps
* Expected inputs / outputs
* Checkpoints or validation moments
* References to scripts where applicable

**Constraints**:

* Linear flow
* Minimal branching (prefer references to other docs if needed)
* No policy discussion

## Optional: deterministic self-checks

To strengthen determinism and trust, a skill may include one or both of the following patterns:

- **Validation script**: a read-only self-check that verifies required resources exist and that declared invariants hold (for example: required files present, schemas valid, outputs conform).
- **Demo script**: a deterministic demonstration that operates only on bundled assets/fixtures and produces clearly-scoped outputs (or a dry-run) to show the skill’s behavior end-to-end.

These are conventions, not doctrine. If used, the procedure should reference them explicitly and keep them safe to re-run.

> This is where determinism lives.
