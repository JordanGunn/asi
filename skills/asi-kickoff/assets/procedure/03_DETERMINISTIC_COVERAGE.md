# Step 1 — Map Maximum Deterministic Surface

The agent must identify **everything that can be made deterministic**, even if trivial.

Determinism should be maximized to the point where further reduction would be meaningless.

## Examples (non-exhaustive)

* File enumeration
* Hash comparison
* Timestamp comparison
* Existence checks
* Stable ordering
* Explicit scope narrowing
* Detecting “nothing changed”

Even simple mechanisms (e.g. comparing `mtime` to current time) are preferred over judgment.

## For each deterministic mechanism, document

* Inputs
* Outputs
* Failure conditions
* Idempotent behavior
* Observable signals (exit codes, files, hashes)

## Determinism Rule

Deterministic mechanisms must be **complete or omitted**.

If a process can be partially deterministic, the deterministic portion must still be declared, and the remainder explicitly surfaced as judgment.

No hybrid ambiguity is allowed.
