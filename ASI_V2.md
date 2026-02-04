# ASI V2: CLI-Centered Skills, Deterministic Loading, and Canon Refresh

## Purpose

This document replaces `ASI_UPDATES_DRAFT.md` as the non-draft, consolidated specification update. It aligns ASI’s skill model with the proven aux pattern while reconciling these changes against ASI’s existing specs, principles, and skill pipeline.

This is the authoritative migration reference to guide changes to ASI documentation and reference skills.

## Motivation (Grounded in aux Outcomes)

Aux validated several structural upgrades that improve determinism and reduce agent entropy.

- Agent-owned CLI as the capability boundary and dependency bundle.
- Deterministic loading of references via a wrapper `init` command.
- Schema ownership in the CLI (emitted on demand).
- Smaller, stricter reference canon (4 files) with ordered loading.
- Thin, stable wrappers with a shared interface.

These align directly with ASI’s principles of deterministic maximalism, surface reduction, entropy control, and explicit boundaries.

## Canonical Changes (Summary)

1. **Adopt an agent-owned CLI boundary** for skills.
2. **Require deterministic reference loading** via `init` in wrappers.
3. **Move schema ownership to the CLI** and deprecate assets-based schemas.
4. **Replace the reference canon** with a 4-file minimal set.
5. **Standardize wrapper interfaces** across shell + PowerShell.

## 1) Agent-Owned CLI Boundary (Required)

### Description

A skill is not just a Markdown contract; it binds to an agent-owned CLI that provides the deterministic boundary implied by ASI’s boundary rule.

- Bundles system dependencies in a single installation.
- Enforces the policy boundary for allowed commands and bounded output.
- Emits schemas deterministically via `--schema`.
- Provides canonical help text that documents the surface.
- Provides read-only validation via `doctor` or `validate`.

### CLI Guarantees (Normative)

The CLI **must** provide the following guarantees.

- Deterministic output ordering for equivalent inputs.
- Bounded output size with explicit truncation signals.
- Dependency isolation with no implicit reliance on host tools.
- A stable schema emission path: `<cli> <skill> --schema`.

### Implications

- Skills depend on the CLI, not arbitrary system tools.
- Asset files are no longer required for schemas or templates.
- The CLI is the single source of truth for schemas and validations.

## 2) Deterministic Loading via `init` (Required)

### Description

Skill wrappers **must** implement a deterministic `init` command that concatenates references in a fixed order. This reduces tool calls and avoids ad-hoc file reading.

### Required Wrapper Interface

Both `skill.sh` and `skill.ps1` must support the same command surface.

- `help`
- `init`
- `validate`
- `schema`
- `run`

The `run` command **must** accept a `--stdin` plan mode.

### Wrapper Contract (Normative)

- `schema` outputs JSON Schema, and the CLI declares the draft version.
- `validate` returns non-zero on failure and is read-only.
- `run --stdin` accepts a single plan object and emits deterministic output.
- All wrapper commands are safe to re-run.

## 3) CLI-Owned Schemas (Replace assets)

### Description

Schemas are no longer maintained as static assets in skill directories. The CLI is the single source of truth and emits JSON schemas on demand.

### Requirement

- `<cli> <skill> --schema` must emit the plan schema.
- `skill.sh schema` and `skill.ps1 schema` must proxy to the CLI.
- `metadata.assets` usage for schemas and templates is deprecated.

### Migration Policy (Assets)

- New skills do not use assets-based schemas or templates.
- Existing skills may retain assets-based schemas and templates during migration, but they must be flagged as legacy and scheduled for removal.

## 4) Canonical Reference Set (Updated)

### New Canon

```text
references/
├── 01_SUMMARY.md
├── 02_INTENT.md
├── 03_POLICIES.md
└── 04_PROCEDURE.md
```

### File Definitions

`01_SUMMARY.md` defines identity and scope, including what the skill does, what it does not do, and high-level constraints.

`02_INTENT.md` defines how natural language intent is compiled into deterministic parameters, includes a schema pointer (`<cli> <skill> --schema`), and sets guardrails for scope and derivation.

`03_POLICIES.md` encodes “Always” and “Never” rules, including hard invariants and prohibited behavior.

`04_PROCEDURE.md` defines the canonical step-by-step execution path, where validation is run, and where artifacts are emitted.

### Optional Routing (`00_ROUTER.md`)

`00_ROUTER.md` becomes **optional** and is used only for complex routing or idempotent lifecycle behaviors. The default loading model is ordered by filename.

1. Run `init`.
2. Read the concatenated references in order.

If a router exists, it must be read first and must declare which references to load.

## 5) Wrapper + CLI Alignment (Required)

All skill wrappers should converge on a shared CLI-first model.

- `init` is the deterministic reference loader.
- `validate` is the CLI `doctor` or equivalent dependency check.
- `schema` is CLI schema emission.
- `run` is CLI execution, using simple args or `--stdin` plan mode.

This enforces predictable behavior and aligns the skill boundary with deterministic execution.

## Required Documentation Updates (Authoritative List)

### Core Specs

`docs/design/specs/references/05_CANON.md`: replace the 8-file canon with the 4-file canon.

`docs/design/specs/references/06_VALIDATION.md`: update the validation checklist to the 4-file canon.

`docs/design/specs/references/files/.INDEX.md`: replace the file list with the 4-file canon.

`docs/design/specs/references/files/`: replace `02_CONTRACTS`, `03_TRIGGERS`, `04_NEVER`, `05_ALWAYS`, `07_FAILURES` with `02_INTENT`, `03_POLICIES`, `04_PROCEDURE`, and align `01_SUMMARY` to the new canon.

### Skill.md Specs

`docs/design/specs/skillmd/02_FRONTMATTER.md`: deprecate `metadata.assets` for schemas and templates, introduce CLI ownership for schemas and templates, and standardize the wrapper interface (`help/init/validate/schema/run`).

`docs/design/specs/skillmd/04_EXAMPLE.md`: remove assets usage from the example and show `metadata.scripts` with the wrapper interface.

`docs/design/specs/skillmd/05_SKILL_CONTRACT_TEMPLATE.md`: replace references to `metadata.assets` and assets-based schemas, and require schema retrieval via CLI (`--schema`).

### Principles

`docs/design/principles/03_ENTROPY_CONTROL.md`: update “assets” language to “CLI-owned schemas/templates” and emphasize deterministic schema emission and wrapper loading.

### Model / Boundaries

`docs/design/model/04_BOUNDARIES.md`: clarify the CLI boundary as deterministic reality.

### Skill Reference Docs

Existing skill references and `SKILL.md` files that enumerate `assets/` should be updated or flagged as legacy.

- `skills/asi-kickoff/SKILL.md`
- `skills/asi-onboard/SKILL.md`
- `skills/asi-exec/SKILL.md`
- `skills/asi-plan/SKILL.md`
- `skills/asi-*` references that mention asset schemas or templates

## Additional Notes

- The `scan` composite pattern (find → grep pipeline) can be documented as a canonical example of a CLI-owned composite skill.
- Output formatting and truncation should be treated as part of deterministic boundary guarantees, with implementation details in the CLI.

## Summary

ASI V2 establishes a CLI-centered skill boundary, deterministic reference loading, and a reduced reference canon. It formally deprecates assets-based schemas in favor of CLI-owned schema emission, and standardizes wrapper interfaces across platforms. This document is the definitive migration target for updating ASI documentation and reference skills.
