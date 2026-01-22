---
description: Reasoning/compilation contracts that bridge `/glob <prompt>` intent to deterministic CLI arguments.
index:
  - Contract
  - Determinism
  - Guardrails
  - Mapping
---

# Contracts

## Contract

`/glob <prompt>` is treated as intent. The agent MUST compile it into two ephemeral JSON receipts:

1. `glob_intent_v1` (what the user wants)
2. `glob_plan_v1` (explicit CLI args to run)

Schemas:

- `assets/schemas/glob_intent_v1.schema.json`
- `assets/schemas/glob_plan_v1.schema.json`

The compiled plan MUST map 1:1 to CLI flags (no implicit scope).

Templates/examples:

- `assets/templates/glob_intent_v1.template.json`
- `assets/templates/glob_plan_v1.template.json`

Run `scripts/skill.sh run --stdin` to validate the compiled receipt and execute the enumeration.

## Determinism

- Normalize intent JSON with stable key ordering, no whitespace, and UTF-8.
- Compute `intent_hash = "sha256:" + sha256(normalized_intent_json)`.
- Keep all lists stable-sorted where order is not semantically meaningful.
- Never emit timestamps or nondeterministic IDs in receipts.

## Guardrails

- Enumerate-before-read: file discovery MUST precede deep file reading.
- Explicit scope: every run declares `root`, `pattern`, `exclude`, `type`, and caps.
- Absence is data: empty results MUST be reported with full scope context.
- Ephemeral receipts: do NOT write plan/intent artifacts to disk unless explicitly asked.

## Mapping (must stay explicit)

- Static guardrails: schema fields, caps (`max_*`), canonical excludes.
- Quantitative outputs: file lists, counts, type distributions.
- Qualitative judgment: choosing patterns/scope/type filters (agent domain).
