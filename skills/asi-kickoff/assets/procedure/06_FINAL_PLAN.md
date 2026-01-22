# Step 4 — Prepare Final Implementation Plan

The agent produces a **reviewable implementation plan**.

This plan must include:

* Scripts to be written (by purpose, not code)
* Assets to be defined
* Validation mechanisms
* Deterministic vs judgment boundaries
* Explicit non-goals
* Known risks and rot vectors

## Lifecycle Declaration (Mandatory)

The plan must explicitly state:

* Persistent artifacts
* Fresh vs resumed invocation
* Completion criteria
* Reset or teardown mechanism
* Staleness detection strategy

If lifecycle cannot be declared without guessing, the plan is incomplete.
