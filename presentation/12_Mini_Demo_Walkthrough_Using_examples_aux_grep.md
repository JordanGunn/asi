# Mini Demo: A Simple Skill in Practice (`skills/asi-creator`)

<!-- fit -->

## Goal (3–5 minutes)

Show what “a real skill” looks like on disk:

- a manifest (`SKILL.md`)
- an instruction surface (`references/`)
- deterministic guardrails (CLI-emitted schemas)
- deterministic entrypoints (`scripts/`)

## Suggested live walkthrough path

1) Open `skills/asi-creator/SKILL.md` (declared surface)
2) Open `skills/asi-creator/references/04_PROCEDURE.md` (ordered steps)
3) Open `skills/asi-creator/scripts/skill.sh` + `skills/cli/src/asi/creator/*` (guardrails + determinism)
4) Run `asi creator --schema` (schema emission is CLI-owned)

<!--
Optional prompt:
- “Which parts are policy vs mechanics?”
  - Policy: contracts/boundaries/procedure/failures
  - Mechanics: search/validation/formatting (scripts)
-->
