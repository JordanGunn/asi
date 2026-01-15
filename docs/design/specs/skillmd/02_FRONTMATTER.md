# Frontmatter Fields

This document defines the canonical `SKILL.md` YAML frontmatter fields

## Canonical top-level fields

### `name`

- Type: `string`
- Purpose: Canonical identifier for the skill

### `description`

- Type: `string`
- Purpose: Human-readable summary of what the skill does

## Metadata Sub-fields

`metadata` is the primary implementation extension point. It is intentionally user-defined, but some repositories adopt a canonical shape for consistency.

### `metadata.author`

- Type: `string`
- Purpose: Skill author/maintainer

### `metadata.references`

- Type: `string[]`
- Purpose: Ordered list of Markdown reference files that contain the skill’s instructions and supporting material. Paths are relative to the skill directory.

### `metadata.scripts`

- Type: `string[]`
- Purpose: List of script entrypoints used by the skill (typically shell + PowerShell variants). Paths are relative to the skill directory.
- Notes: Scripts often include a read-only validation entrypoint and may include a deterministic demo entrypoint that operates only on bundled assets/fixtures.

### `metadata.assets`

- Type: `string[]`
- Purpose: List of static supporting files shipped with the skill (examples, fixtures, etc.). Paths are relative to the skill directory.
- Notes: Assets may include small fixtures intended for deterministic self-checking or demonstration.

### `metadata.artifacts`

- Type: `string[]`
- Purpose: List of expected/generated outputs (may be empty). This is reserved for workflow output conventions.

### `metadata.keywords`

- Type: `string[]`
- Purpose: Search/discovery keywords.

## Utilization guidance (implementation-facing)

These fields are most useful when they are treated as deterministic inputs to discovery, routing, and validation. The guidance below describes common, safe usage patterns.

### Using `metadata.references`

- Treat the listed files as the skill’s declared instruction surface.
- Prefer reading references in the listed order unless a router explicitly routes to a subset.
- If a reference file is listed but missing, fail loudly rather than improvising new instructions.

### Using `metadata.scripts`

- Treat scripts as deterministic entrypoints, not as “smart helpers”.
- Validation scripts should be read-only and safe to re-run.
- Demo scripts should operate only on bundled assets/fixtures and should not touch external state.
- If a script is declared but missing, fail loudly rather than silently skipping it.

### Using `metadata.assets`

- Treat assets as the skill’s self-contained support surface (fixtures, schemas, templates, examples).
- If assets are referenced by procedure/validation, missing assets should cause failure.
- Prefer assets that reduce entropy and constrain reasoning space:
  - schemas for inputs/outputs and persistent state
  - templates for expected artifacts and canonical formats
  - controlled vocabularies or enums where naming drift matters
- Use fixtures primarily for deterministic self-checks and demos that do not touch external state.

### Using `metadata.artifacts`

- Treat listed artifacts as declared outputs when the skill produces outputs.
- If artifacts are declared, validation should make it easy to determine whether they exist and conform.
- Avoid implying success when declared artifacts are missing.
