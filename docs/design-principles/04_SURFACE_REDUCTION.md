# 04. Reduce the Reasoning Surface Before Reasoning Begins

Avoid reasoning over an unbounded or ambiguous surface.

- Reduce the problem space first using deterministic discovery mechanisms.
- Enumerate, filter, and constrain what can be seen before asking an agent to decide.
- Discovery defines reality; reasoning operates within that reality.

Smaller, well-defined surfaces reduce tool calls, preserve context, and lower token cost.

## Why this matters for ASI

This is the practical form of determinism-before-reasoning: enumerate and narrow the surface first, then interpret within the bounded set, with clear scope reporting (`docs/spec/rfc-0001-asi.md`).
