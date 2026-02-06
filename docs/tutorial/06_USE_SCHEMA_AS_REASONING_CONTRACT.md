# Use Schema as Reasoning Contract

## Goal

- show how schema constrains planning so agent reasoning is explicit and auditable.

## Why This Matters

- schema prevents undocumented parameters from entering execution.
- schema-first planning aligns interpretation with the reasoning contract at the deterministic boundary.

## What To Do

- retrieve schema before building any plan.
- generate plans using only schema-declared fields and allowed values.
- execute and refine through declared reasoning contract fields only.

## What To Avoid

- inferring hidden plan fields.
- treating schema examples as optional suggestions.
- allowing divergence between help and schema semantics.

## Governance Tie-In

This step protects reasoning contract integrity and reduces schema/behavior drift risk.

## Normative References

- `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`
- `docs/design/specs/skillmd/05_SKILL_CONTRACT_TEMPLATE.md`
- `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`
- `docs/implementation/08_MEASUREMENT_PROTOCOL.md`

## Checkpoint

- Evidence required: sample plan annotated with schema field references.
- Pass condition: every field in the plan maps to a declared schema field and allowed type/value shape.
- Common failure signal: plan contains undeclared or implicitly derived fields.
