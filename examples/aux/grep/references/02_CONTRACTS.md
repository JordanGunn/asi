---
description: Reasoning/compilation contracts that bridge `/grep <prompt>` intent to deterministic CLI arguments.
index:
  - Contract
  - Determinism
  - Guardrails
  - Mapping
---

# Contracts

## Contract

`/grep <prompt>` is treated as intent. The agent MUST compile it into two ephemeral JSON receipts:

1. `grep_intent_v1` (what the user wants)
2. `grep_plan_v1` (explicit CLI args to run)

Schemas:

- `assets/schemas/grep_intent_v1.schema.json`
- `assets/schemas/grep_plan_v1.schema.json`

The compiled plan MUST map 1:1 to CLI flags (no implicit scope).

Templates/examples:

- `assets/templates/grep_intent_v1.template.json`
- `assets/templates/grep_plan_v1.template.json`

Run `scripts/skill.sh run --stdin` to validate the compiled receipt and execute the search.

## Determinism

- Normalize intent JSON with stable key ordering, no whitespace, and UTF-8.
- Compute `intent_hash = "sha256:" + sha256(normalized_intent_json)`.
- Keep all lists stable-sorted where order is not semantically meaningful (globs, excludes).
- Never emit timestamps or nondeterministic IDs in receipts.

## Guardrails

- Search-before-read: compilation and search MUST precede deep file reading.
- Explicit scope: every run declares `root`, `glob`, `exclude`, and caps.
- Absence is data: empty hits MUST be reported with scope + counts.
- Ephemeral receipts: do NOT write plan/intent artifacts to disk unless explicitly asked.

## Mapping (must stay explicit)

- Static guardrails: schema fields, caps (`max_*`), canonical excludes.
- Quantitative outputs: hit records, counts, file distributions.
- Qualitative judgment: choosing terms/scope/strategy (agent domain).
