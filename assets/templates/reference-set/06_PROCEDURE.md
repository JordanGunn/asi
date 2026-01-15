# 06_PROCEDURE.md Template

---
description: Step-by-step procedure from inputs to outputs.
index:
  - Inputs
  - Steps
  - Validation
  - Resume
---

## Inputs

- Enumerate inputs and what they mean for scope.
- If frontmatter is used, clarify how it relates to these inputs (references/scripts/assets/artifacts).
  - If assets include schemas/templates, state which validations they enable and which outputs they constrain.

## Steps

1. Deterministic discovery (define the universe).
2. Deterministic narrowing (reduce scope read-only).
3. Deterministic execution (optional mutation).
4. Deterministic validation (prove completion).
5. Interpretation (only after deterministic steps).
6. Reporting / artifact creation.

## Validation

- Describe the checks that prove completion.
- If artifacts are declared, state what validation makes their existence and conformance checkable.

## Resume

- If the router can jump here, describe how to resume safely.

## Optional: deterministic self-checks

- Validation script: read-only self-check of prerequisites, schemas, and declared invariants.
- Demo script: deterministic run over bundled fixtures only, producing clearly-scoped outputs (or a dry-run).
