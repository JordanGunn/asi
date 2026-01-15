# 01_SUMMARY.md Template

---
description: One-page summary of what the skill does and how to invoke it safely.
index:
  - Purpose
  - Inputs
  - Outputs
  - Observability
---

## Purpose

- What this skill does.
- What this skill does not do.

## Inputs

- Primary argument: a user prompt (natural language).
- Optional: additional structured parameters provided by the hosting environment (if any). If present, treat them as explicit scope/execution controls and report them.
- List any derived inputs that determine scope and execution (scope, filters, targets).
- Describe any defaults and their scope implications.

## Outputs

- Describe expected outputs and/or artifacts (if any).
- If artifacts are declared, mention the validation gate used to prove completion.

## Observability

State what the skill will report so the run is auditable:

- effective scope (in-bounds surface)
- what was read
- what was written or changed
- validation status
