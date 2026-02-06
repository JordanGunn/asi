# Define Agent Job and Boundary

## Goal

- specify exactly what the agent should do and what deterministic mechanisms should do for a grep-style skill.

## Why This Matters

- explicit boundaries prevent hidden assumptions and improve failure diagnosis.
- stable division of labor keeps deterministic execution reproducible.

## What To Do

- define agent responsibilities: intent shaping, tradeoff selection, refinement decisions.
- define deterministic responsibilities: execution, schema enforcement, stable outputs.
- document anti-patterns where either side overreaches.

## What To Avoid

- agent-selected hidden defaults not represented in help/schema.
- wrappers or CLI performing subjective ranking or semantic interpretation.
- mixed ownership where no component is accountable for reasoning contract enforcement.

## Governance Tie-In

This step protects deterministic boundary ownership and auditable reasoning scope.

## Normative References

- `docs/design/model/04_BOUNDARIES.md`
- `docs/design/specs/scripts/03_CLI_BOUNDARY.md`
- `docs/design/principles/02_SUBJECTIVE_MINIMILISM.md`
- `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`

## Checkpoint

- Evidence required: five-task classification table with rationale per row.
- Pass condition: deterministic tasks map to execution/validation, judgment tasks map to interpretation/refinement.
- Common failure signal: “agent convenience” used as justification for deterministic work.
