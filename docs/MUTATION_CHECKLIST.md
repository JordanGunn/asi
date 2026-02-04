# Mutation Checklist (ASI V2 Migration)

This file enumerates documentation and skill surfaces that still reference the V1 canon or assets-based schemas/templates. It is the working checklist for the update pass.

## Specs and Indices

- [x] `docs/design/specs/references/05_CANON.md` (verify V2 canon)
- [x] `docs/design/specs/references/06_VALIDATION.md` (verify V2 checklist)
- [x] `docs/design/specs/references/files/.INDEX.md` (verify V2 index)
- [x] `docs/design/specs/references/files/00_ROUTER.md` (optional router language)
- [x] `docs/design/specs/references/files/01_SUMMARY.md` (verify content)
- [x] `docs/design/specs/references/files/02_INTENT.md` (new)
- [x] `docs/design/specs/references/files/03_POLICIES.md` (new)
- [x] `docs/design/specs/references/files/04_PROCEDURE.md` (new)
- [x] `docs/design/specs/skillmd/02_FRONTMATTER.md` (assets + wrapper interface)
- [x] `docs/design/specs/skillmd/04_EXAMPLE.md` (new canon)
- [x] `docs/design/specs/skillmd/05_SKILL_CONTRACT_TEMPLATE.md` (CLI schema)
- [x] `docs/design/specs/scripts/.INDEX.md` (new section)
- [x] `docs/design/specs/scripts/01_OVERVIEW.md`
- [x] `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`
- [x] `docs/design/specs/scripts/03_CLI_BOUNDARY.md`
- [x] `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`
- [x] `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md`
- [x] `docs/design/specs/scripts/06_INSTALLATION.md`

## Principles and Model

- [x] `docs/design/principles/01_DETERMINISTIC_MAXIMILISM.md` (schema validation wording)
- [x] `docs/design/principles/03_ENTROPY_CONTROL.md` (CLI-owned schemas/templates)
- [x] `docs/design/principles/06_DOMAIN_MAPPING.md` (schemas/templates wording)
- [x] `docs/design/principles/07_LANGUAGE_NOT_A_CRUTCH.md` (schema asset references)
- [x] `docs/design/model/04_BOUNDARIES.md` (CLI boundary)

## Skills README

- [x] `skills/README.md` (reading order and reference canon)

## Skills (V1 Canon References)

- [x] `skills/asi-onboard/SKILL.md`
- [x] `skills/asi-plan/SKILL.md`
- [x] `skills/asi-kickoff/SKILL.md`
- [x] `skills/asi-exec/SKILL.md`
- [x] `skills/asi-onboard/references/00_ROUTER.md`
- [x] `skills/asi-plan/references/00_ROUTER.md`
- [x] `skills/asi-kickoff/references/00_ROUTER.md`
- [x] `skills/asi-exec/references/00_ROUTER.md`
- [x] `skills/asi-onboard/references/02_CONTRACTS.md`
- [x] `skills/asi-plan/references/02_CONTRACTS.md`
- [x] `skills/asi-kickoff/references/02_CONTRACTS.md`
- [x] `skills/asi-exec/references/02_CONTRACTS.md`
- [x] `skills/asi-onboard/references/03_TRIGGERS.md`
- [x] `skills/asi-plan/references/03_TRIGGERS.md`
- [x] `skills/asi-kickoff/references/03_TRIGGERS.md`
- [x] `skills/asi-exec/references/03_TRIGGERS.md`
- [x] `skills/asi-onboard/references/04_NEVER.md`
- [x] `skills/asi-plan/references/04_NEVER.md`
- [x] `skills/asi-kickoff/references/04_NEVER.md`
- [x] `skills/asi-exec/references/04_NEVER.md`
- [x] `skills/asi-onboard/references/05_ALWAYS.md`
- [x] `skills/asi-plan/references/05_ALWAYS.md`
- [x] `skills/asi-kickoff/references/05_ALWAYS.md`
- [x] `skills/asi-exec/references/05_ALWAYS.md`
- [x] `skills/asi-onboard/references/06_PROCEDURE.md`
- [x] `skills/asi-plan/references/06_PROCEDURE.md`
- [x] `skills/asi-kickoff/references/06_PROCEDURE.md`
- [x] `skills/asi-exec/references/06_PROCEDURE.md`
- [x] `skills/asi-onboard/references/07_FAILURES.md`
- [x] `skills/asi-plan/references/07_FAILURES.md`
- [x] `skills/asi-kickoff/references/07_FAILURES.md`
- [x] `skills/asi-exec/references/07_FAILURES.md`

## Skills (Assets + Schemas + Templates)

- [ ] `skills/asi-onboard/assets/` (legacy; to be removed in skill migration)

## Skills (Scripts That Reference Assets)

- [x] `skills/asi-onboard/scripts/` (replaced with CLI wrappers)

## Changelog and Other Docs

- [ ] `docs/CHANGELOG.md` (schema assets)
