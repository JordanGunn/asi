---
description: Schema contract for compiling `/grape <prompt>` into explicit grep args.
index:
  - Contract
  - Determinism
  - Guardrails
  - Mapping
---

# Compiler Contract

## Contract

`/grape <prompt>` is treated as intent. The agent MUST compile it into two ephemeral JSON receipts:

1. `grape_intent_v1` (what the user wants)
2. `grape_compiled_plan_v1` (explicit CLI args to run)

Schemas:

- `assets/schemas/grape_intent_v1.schema.json`
- `assets/schemas/grape_compiled_plan_v1.schema.json`
- `assets/schemas/grape_surface_plan_v1.schema.json`

The compiled plan MUST map 1:1 to `grape grep` flags (no implicit scope).
The surface plan maps 1:1 to `grape scan` arguments and must be run before finalizing search terms.

Templates/examples:

- `assets/templates/grape_intent_v1.template.json`
- `assets/templates/grape_compiled_plan_v1.template.json`
- `assets/examples/grape_compiled_plan_v1.example.json`
- `assets/templates/grape_surface_plan_v1.template.json`
- `assets/examples/grape_surface_plan_v1.example.json`

Run `scripts/plan.sh`/`scripts/plan.ps1 --stdin` to validate the compiled receipt, emit it as
`kind: compiled_plan`, and then execute the explicit grep arguments before returning results.

## Determinism

- Normalize intent JSON with stable key ordering, no whitespace, and UTF-8.
- Compute `intent_hash = "sha256:" + sha256(normalized_intent_json)`.
- Keep all lists stable-sorted where order is not semantically meaningful (globs, excludes).
- Never emit timestamps or nondeterministic IDs in receipts.

## Guardrails

- Search-before-read: compilation and search MUST precede deep file reading.
- Explicit scope: every run declares `root`, `glob`, `exclude`, and caps.
- Enforcement path: `grape plan --plan <path>` validates the schema, prints the receipt, and fires `grape grep`.
- Absence is data: empty hits MUST be reported with scope + counts, plus one widening axis.
- Parallel/cascade are strategies: optional, bounded, and recorded via ledgers.
- Ephemeral receipts: do NOT write plan/intent artifacts to disk unless explicitly asked.

## Mapping (must stay explicit)

- Static guardrails: schema fields, caps (`max_*`), canonical excludes, derived-token filters.
- Quantitative outputs: surface snapshot, hit records, counts, probe/derivation ledgers.
- Qualitative judgment: choosing terms/scope/strategy justified only by the snapshot (no repo claims).
