# 09. Don’t Use Natural Language as a Crutch for Poor Design

Natural language is a powerful interface. It should not compensate for:

- missing determinism
- undefined schemas/templates
- unbounded discovery
- ambiguous authority

If a rule matters, encode it structurally. If a decision matters, constrain it explicitly.

This is compatible with skills taking a single user prompt as input: the prompt is the interface, but determinism provides the guardrails.

## Why this matters for ASI

ASI treats natural language as the interface while insisting that behavior is governed by explicit constraints. This principle protects determinism-before-reasoning from being replaced by “prompt-only” governance (`docs/spec/rfc-0001-asi.md`).
