# 08. Map Static, Quantitative, and Qualitative Domains Explicitly

Distinguish the domains of information before implementation:

- Static information: guardrails that constrain reasoning (schemas, templates, fixed references)
- Quantitative outcomes: deterministic results produced by tools
- Qualitative judgment: subjective decisions made by agents when determinism cannot apply

Make this mapping explicitly; avoid inferring it after the fact.

## Why this matters for ASI

ASI works best when deterministic truth, static guardrails, and subjective judgment are not blended. Explicit domain mapping reduces scope drift and improves auditability (`docs/spec/rfc-0001-asi.md`).
