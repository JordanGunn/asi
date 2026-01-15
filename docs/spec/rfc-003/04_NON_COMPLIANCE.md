# Non-compliance (hard failures)

An implementation is **non-compliant** if any of the following occur:

- Hidden mutation: state changes without explicit invocation and reporting.
- Background behavior: maintenance, auto-repair, or “help” occurs without explicit user intent.
- Reasoning precedes reduction: the agent reasons over an unconstrained corpus instead of enumerating and narrowing deterministically first.
- Silent scope widening: the system expands scope without being explicit about why and what changed.
- Partial success presented as success: declared guarantees or artifacts are missing but the run is reported as “done”.
