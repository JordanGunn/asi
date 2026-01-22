# 09. Don’t Use Natural Language as a Crutch for Poor Design

Natural language is a powerful interface. It should not compensate for:

- missing determinism
- undefined schemas/templates
- unbounded discovery
- ambiguous authority

If a rule matters, encode it structurally. If a decision matters, constrain it explicitly.

This is compatible with skills taking a single user prompt as input: the prompt is the interface, but determinism provides the guardrails.

## Parameterized determinism (best practice)

When agents provide parameters to deterministic mechanisms (scripts, queries, routers), define a reasoning contract asset.

That contract should declare the parameter schema, allowed values, defaults, and derivation rules, and it should require explicit reporting of the derived parameters.

This keeps natural language as the input while preventing hidden or ad hoc reasoning from controlling deterministic execution.

## Why this matters for ASI

ASI treats natural language as the interface while insisting that behavior is governed by explicit constraints. This principle protects determinism-before-reasoning from being replaced by "prompt-only" governance.
