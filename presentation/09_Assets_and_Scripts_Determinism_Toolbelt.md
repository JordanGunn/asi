# `assets/` + `scripts/`: The Determinism Toolbelt

## `assets/` (static guardrails)

- Schemas: constrain inputs/outputs (“reasoning contracts”)
- Templates: canonical formats (reduce “creative formatting”)
- Fixtures: deterministic demos/self-checks (no external state)

## `scripts/` (deterministic entrypoints)

- Mechanical operations the agent should *not* improvise:
  - discovery (enumeration)
  - validation
  - transformation (inject/format/build artifacts)

## Rule of thumb

- If it can be mechanized, **script it**
- Let the agent do what’s left: **bounded judgment**

<!--
Speaker notes:
- Principles: `docs/design/principles/01_DETERMINISTIC_MAXIMILISM.md`, `docs/design/principles/03_ENTROPY_CONTROL.md`
-->
