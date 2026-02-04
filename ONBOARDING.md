# ASI Onboarding Notes (Aux Skill Discoveries)

## Context

This repo (ASI) is being updated based on concrete discoveries from a separate “aux” skills implementation (external to this repository). The goal is to modernize ASI’s skill interface standards and documentation to match what has proven effective in practice.

A separate proposal document exists at `ASI_UPDATES_DRAFT.md` and captures the full monolithic changeset. This file is a quick onboarding summary for a new agent.

## Key Discoveries From aux Skills

1. **Agent-owned CLI as the execution boundary**
   - A dedicated CLI (`aux`) bundles dependencies and enforces a policy boundary.
   - Skills call the CLI; they do not call system tools directly.
   - This improves dependency management, installation, and determinism.

2. **Deterministic loading via `init`**
   - Skill wrappers implement `init` to concatenate reference files in a fixed order.
   - This reduces tool calls, improves determinism, and preserves context budget.

3. **Schemas live in the CLI**
   - Schemas are generated from Pydantic models in the CLI.
   - Skills fetch schemas with `aux <skill> --schema`.
   - Schema assets inside skill directories are no longer needed.

4. **Minimal reference canon**
   - The aux skills reduced references to four files:
     - `01_SUMMARY.md`
     - `02_INTENT.md`
     - `03_POLICIES.md`
     - `04_PROCEDURE.md`
   - This replaces the older 8-file canon and eliminates router complexity unless needed.

5. **Wrapper interface standardization**
   - The minimal wrapper interface is:
     - `help`, `init`, `validate`, `schema`, `run`
   - `run` must support `--stdin` plan mode.

## Evidence From aux

The aux implementation included:

- A small set of “reference skills” (e.g. `diff`, `find`, `grep`, `ls`) bound to a single agent-owned CLI.
- A CLI implementation that owned schemas, validation, and deterministic execution boundaries.

Core files:

- `cli/src/aux/cli.py` (subcommands + help)
- `cli/src/aux/plans/schemas.py` (Pydantic schemas)
- `cli/src/aux/commands/*.py` (command logic)
- `skills/*/scripts/skill.sh` (wrapper interface)

## Changes Expected in ASI

The ASI spec will be updated to reflect the new canon:

- **Agent-owned CLI** is now the preferred boundary for deterministic execution.
- **Schemas** are CLI-owned (remove asset schema guidance in docs).
- **References canon** changes from 8 files to 4.
- **Wrapper interface** must include `init` (both shell and PowerShell).
- Documentation about `assets/` should be removed or deprecated in favor of CLI-managed assets.

## Where ASI Needs Updates

Relevant ASI docs that currently encode the old model:

- `docs/design/specs/references/05_CANON.md`
- `docs/design/specs/references/06_VALIDATION.md`
- `docs/design/specs/references/files/.INDEX.md`
- `docs/design/specs/skillmd/02_FRONTMATTER.md`
- `docs/design/specs/skillmd/04_EXAMPLE.md`
- `docs/design/specs/skillmd/05_SKILL_CONTRACT_TEMPLATE.md`
- `docs/design/principles/03_ENTROPY_CONTROL.md`

## Current Draft

See `ASI_UPDATES_DRAFT.md` for the detailed monolithic proposal.

## Open Questions

- Should `00_ROUTER.md` be optional or formally deprecated?
- Do we need a new `metadata.cli` field to declare the CLI dependency explicitly?
- Should assets be removed entirely or kept for legacy skills?
