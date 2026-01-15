# 04_ALWAYS.md — Non-negotiable invariants

**Purpose**:

* Encode rules that must *always* hold true
* Establish agent invariants independent of task specifics

**Contains**:

* Hard requirements
* Mandatory checks
* Invariants (idempotency, determinism, cleanup rules, etc.)

**Examples**:

* “Always verify X before Y”
* “Always leave the repo in a clean state”
* “Always prefer deterministic discovery over inference”

**Constraints**:

* Absolute language only (always / must)
* No branching
* No task-specific logic

> If violated, the skill is considered **incorrectly executed**.
