# Example 03: Failure Semantics

## Scenario

A skill declares an artifact: “Produce a conformance report.”

## ASI-compliant behavior

- If the artifact cannot be produced, the skill fails loudly.
- The failure identifies what guarantee could not be upheld (e.g., validation failed; required inputs missing).
- The system does not claim completion.

## Non-compliant behavior

- Producing a partial report but claiming “done”.
- Swallowing errors and continuing silently.
- Widening scope to “make it work” without explicit reporting.

## Key principle

Failure is better than ambiguity: partial success is corruption with better PR.

