---
description: Reasoning/compilation contracts that bridge `/re <prompt>` intent to deterministic regex patterns.
index:
  - Contract
  - Determinism
  - Guardrails
  - Mapping
---

# Contracts

## Contract

`/re <prompt>` is treated as intent. The agent MUST compile it into two ephemeral JSON receipts:

1. `regex_intent_v1` (what the user wants to match/extract)
2. `regex_plan_v1` (explicit pattern and execution args)

Schemas:

- `assets/schemas/regex_intent_v1.schema.json`
- `assets/schemas/regex_plan_v1.schema.json`

The compiled plan MUST contain a valid regex pattern and execution parameters.

Templates/examples:

- `assets/templates/regex_intent_v1.template.json`
- `assets/templates/regex_plan_v1.template.json`

Run `scripts/skill.sh run --stdin` to validate the compiled receipt and execute the pattern.

## Determinism

- Normalize intent JSON with stable key ordering, no whitespace, and UTF-8.
- Compute `intent_hash = "sha256:" + sha256(normalized_intent_json)`.
- Patterns must be valid PCRE2 or Python re syntax.
- Never emit timestamps or nondeterministic IDs in receipts.

## Guardrails

- Pattern-before-parse: regex compilation MUST precede extraction.
- Explicit pattern: every run declares the exact regex, flags, and caps.
- Absence is data: no matches MUST be reported with pattern context.
- Ephemeral receipts: do NOT write plan/intent artifacts to disk unless explicitly asked.

## Mapping (must stay explicit)

- Static guardrails: schema fields, caps (`max_*`), timeout limits.
- Quantitative outputs: match records, capture groups, counts.
- Qualitative judgment: choosing patterns/flags (agent domain).
