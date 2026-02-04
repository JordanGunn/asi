# ASI Updates Draft: Agent-Owned CLI, Deterministic Loading, and Reference Canon

## Purpose

This draft consolidates proposed ASI additions based on the aux skills implementation. It is a single, monolithic proposal intended for review before changes are distributed across ASI docs and reference skills.

## Motivation From aux Skills

The aux skills validate several structural improvements:

- Agent-owned CLI as the capability boundary and dependency bundle.
- Deterministic loading of reference docs through a wrapper `init` command to reduce tool calls.
- Schema ownership in the CLI (Pydantic), emitted on demand (`--schema`).
- Smaller, stricter reference canon (4 files) with ordered loading.
- Script wrappers that are thin and stable, exposing a minimal, shared interface.

These changes reduce agent context pressure, improve determinism, and standardize the execution surface.

## Proposed Canonical Changes (High Level)

1. Add a first-class “agent-owned CLI” pattern to ASI.
2. Require deterministic reference loading via `init` in skill wrappers.
3. Move schema ownership to the CLI and remove assets-based schema guidance.
4. Replace the canonical reference set with the aux reference canon:
   - `01_SUMMARY.md`
   - `02_INTENT.md`
   - `03_POLICIES.md`
   - `04_PROCEDURE.md`
5. Formalize a shared wrapper interface across `skill.sh` and `skill.ps1`.

## Agent-Owned CLI (New Canon)

### Description

A skill is not just a markdown contract. It must bind to an agent-owned CLI that:

- Bundles system dependencies into a single installation.
- Provides the policy boundary (allowed commands, bounded output).
- Emits schemas deterministically (`--schema`).
- Provides canonical help text (self-documenting).\
- Provides read-only validation (`doctor`, `validate`).

### Implications

- Skills depend on the CLI, not arbitrary system tools.
- Asset files are no longer required for schemas or templates.
- The CLI is responsible for type safety, schema generation, and bounded output.

## Deterministic Loading via Wrapper `init`

### Description

Skill wrappers MUST implement a deterministic `init` command that concatenates references in a fixed order. This reduces tool calls and avoids ad-hoc file reading.

### Requirement

Both `skill.sh` and `skill.ps1` must support:

- `help`
- `init`
- `validate`
- `schema`
- `run`

The `--stdin` plan mode must be supported for `run`.

## CLI-Owned Schemas (Replace assets)

### Description

Schemas are no longer maintained as static assets in skill directories. The CLI is the single source of truth and emits JSON schemas on demand.

### Requirement

- `aux <skill> --schema` must emit the plan schema.
- `skill.sh schema` and `skill.ps1 schema` must proxy to the CLI.
- `metadata.assets` should be removed or deprecated in ASI docs and templates.

## Canonical Reference Set (Updated)

### New Canon

```text
references/
├── 01_SUMMARY.md
├── 02_INTENT.md
├── 03_POLICIES.md
└── 04_PROCEDURE.md
```

### File Definitions (Draft)

- `01_SUMMARY.md`
  - Identity and scope of the skill.
  - What it does and does not do.
  - High-level constraints.

- `02_INTENT.md`
  - How natural language intent is compiled into deterministic parameters.
  - Explicit schema pointer (`aux <skill> --schema`).
  - Guardrails for scope and derivation.

- `03_POLICIES.md`
  - “Always” and “Never” rules.
  - Hard invariants and prohibited behavior.

- `04_PROCEDURE.md`
  - Canonical step-by-step execution path.
  - Where validation is run.
  - Where artifacts are emitted.

### Optional Routing

Router files (`00_ROUTER.md`) become optional and are only needed for complex routing or idempotent lifecycle behaviors. The default loading model should be:

1. Run `init`
2. Read the concatenated references in order

## Where ASI Docs Should Change

### Core Specs

- `docs/design/specs/references/05_CANON.md`
  - Replace the 8-file canon with the 4-file canon.

- `docs/design/specs/references/06_VALIDATION.md`
  - Update validation checklist to the 4-file canon.

- `docs/design/specs/references/files/.INDEX.md`
  - Replace file list with the 4 files.

- `docs/design/specs/references/files/` contents
  - Replace `02_CONTRACTS`, `03_TRIGGERS`, `04_NEVER`, `05_ALWAYS`, `07_FAILURES` with:
    - `02_INTENT`
    - `03_POLICIES`
    - `04_PROCEDURE`
  - Keep `01_SUMMARY` but adjust to align with new canon.

### Skill.md Specs

- `docs/design/specs/skillmd/02_FRONTMATTER.md`
  - Remove `metadata.assets` guidance.
  - Introduce CLI ownership for schemas and templates.
  - Standardize wrapper interface (`help/init/validate/schema/run`).

- `docs/design/specs/skillmd/04_EXAMPLE.md`
  - Remove assets usage from the example.
  - Show `metadata.scripts` with the wrapper interface.

- `docs/design/specs/skillmd/05_SKILL_CONTRACT_TEMPLATE.md`
  - Replace references to `metadata.assets` and assets-based schemas.
  - Require schema retrieval via CLI (`--schema`).

### Principles

- `docs/design/principles/03_ENTROPY_CONTROL.md`
  - Update “assets” language to “CLI-owned schemas/templates.”
  - Emphasize deterministic schema emission and wrapper loading.

### Model / Boundaries

- `docs/design/model/04_BOUNDARIES.md`
  - Add a statement clarifying the CLI boundary as deterministic reality.

### Skill Reference Docs

Existing skill reference docs and SKILL.md files that enumerate `assets/` should be updated or flagged for deprecation:

- `skills/asi-kickoff/SKILL.md`
- `skills/asi-onboard/SKILL.md`
- `skills/asi-exec/SKILL.md`
- `skills/asi-plan/SKILL.md`
- `skills/asi-*` references that mention asset schemas or templates

## Changes to ASI Skill Wrappers

All ASI skill wrappers should converge on the aux wrapper model:

- `init`: deterministic reference loader
- `validate`: CLI `doctor` or equivalent dependency check
- `schema`: CLI schema emission
- `run`: CLI execution (simple args or `--stdin` plan)

This aligns skill behavior with the CLI-boundary model and ensures predictable usage.

## Additional Considerations

- The `scan` composite pattern (find → grep pipeline) should be documented as a canonical example of a CLI-owned composite skill.
- Output formatting via `AUX_OUTPUT` and truncation via `AUX_MAX_MATCHES` should be referenced as part of the determinism/bounded output story, if relevant.

## Open Questions

- Should `00_ROUTER.md` be formally deprecated or explicitly optional?
- Do we want a new `metadata.cli` or `metadata.runtime` field to declare the CLI dependency explicitly?
- Should assets be removed entirely from ASI skills, or retained only for legacy skills while new skills are CLI-first?

## Summary

The aux skills provide a strong precedent for a CLI-centered ASI model. The proposed changes simplify reference files, remove asset-driven schemas, and formalize deterministic loading with a minimal wrapper interface. This draft is intended as a single starting point for revising ASI docs and updating reference skills.
