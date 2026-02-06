# Implementation Decision Records

These records explain why ASI V2 implementation constraints were selected.

## Decision Metadata Contract

Each decision record includes:

- `status`: `accepted`, `proposed`, or `superseded`.
- `date`: ISO-8601 date of decision adoption.
- `scope`: implementation concern covered by the decision.
- `normative_sources`: governing design/spec documents.

## DR-001: Canonical 4-File Reference Set

- Status: `accepted`
- Date: `2026-02-06`
- Scope: Reference surface design
- Normative sources: `docs/design/specs/references/05_CANON.md`, `docs/design/specs/references/files/00_ROUTER.md`
- Decision: Standardize to `01_SUMMARY.md`, `02_INTENT.md`, `03_POLICIES.md`, `04_PROCEDURE.md` with optional `00_ROUTER.md`.
- Alternatives considered:
  - 8+ fragmented reference files.
  - Monolithic single reference file.
- Why this decision:
  - Reduces onboarding navigation overhead.
  - Preserves progressive disclosure without file proliferation.
  - Keeps routing semantics explicit when needed.
- Tradeoff:
  - Some topics are less granular than fragmented docs.
- Does not change:
  - Router semantics and optionality requirements already defined in design specs.

## DR-002: Deterministic Control in Agent-Owned CLI

- Status: `accepted`
- Date: `2026-02-06`
- Scope: Execution boundary ownership
- Normative sources: `docs/design/specs/scripts/03_CLI_BOUNDARY.md`, `docs/design/specs/scripts/06_INSTALLATION.md`
- Decision: CLI is the deterministic execution boundary and owns dependencies, policies, and schema emission.
- Alternatives considered:
  - Wrapper-owned logic distributed across shell scripts.
  - Agent-native ad hoc tool usage without CLI mediation.
- Why this decision:
  - Produces reproducible execution behavior.
  - Reduces host runtime drift.
  - Keeps policy checks in one auditable boundary.
- Tradeoff:
  - Requires CLI installation and version management.
- Does not change:
  - Existing wrapper command contract; wrappers remain required.

## DR-003: Wrappers Stay Thin and Canonical

- Status: `accepted`
- Date: `2026-02-06`
- Scope: Wrapper interface and delegation
- Normative sources: `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`, `docs/design/principles/10_PORTABILITY.md`
- Decision: Wrappers expose minimum subcommands and delegate behavior to CLI.
- Alternatives considered:
  - Feature-rich wrappers with business logic.
  - Platform-specific command divergence.
- Why this decision:
  - Improves portability and reviewability.
  - Simplifies debugging and lifecycle behavior.
- Tradeoff:
  - Less convenience logic in wrappers.
- Does not change:
  - Ability to include read-only helper checks where already specified.

## DR-004: CLI Emits Active Schemas/Templates

- Status: `accepted`
- Date: `2026-02-06`
- Scope: Schema/template authority
- Normative sources: `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`, `docs/design/specs/skillmd/02_FRONTMATTER.md`
- Decision: Use CLI-emitted schemas/templates for active contracts.
- Alternatives considered:
  - Store schemas/templates directly under skill assets.
  - Hybrid active sources split across CLI and assets.
- Why this decision:
  - Single source of truth for contract shape.
  - Stronger type-safety alignment between CLI and agent payloads.
  - Lower schema drift risk.
- Tradeoff:
  - Legacy skills require migration and transitional validation.
- Does not change:
  - Legacy fixture/example asset allowance under explicit legacy designation.

## DR-005: Prefer `init` Streaming over Manual File Reads

- Status: `accepted`
- Date: `2026-02-06`
- Scope: Onboarding and scope loading
- Normative sources: `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md`, `docs/design/specs/references/files/00_ROUTER.md`
- Decision: Onboarding should run through deterministic `init` output instead of ad hoc file-by-file reads.
- Alternatives considered:
  - Agent manually reading reference files through native tools.
  - Mixed mode where `init` is optional and mostly bypassed.
- Why this decision:
  - Enforces fixed ordering and scope declaration.
  - Reduces accidental omission of required references.
  - Supports bounded context acquisition.
- Tradeoff:
  - Requires disciplined wrapper behavior and route reporting.
- Does not change:
  - Ability to inspect individual references for diagnostics after `init`.

## Invariant-to-Decision Mapping

| Invariant | Primary decision | Secondary decision |
| --- | --- | --- |
| I1 canonical references | DR-001 | DR-005 |
| I2 CLI boundary | DR-002 | DR-003 |
| I3 wrapper surface | DR-003 | DR-002 |
| I4 schema/template authority | DR-004 | DR-002 |
| I5 deterministic init | DR-005 | DR-001 |

## Supersession Procedure

- A decision update `MUST` add a new DR entry rather than rewriting history.
- Superseding entry `MUST` reference superseded DR IDs and rationale for change.
- Superseding entry `MUST` include updated normative sources.
- Superseded records `MUST` remain in this file with status set to `superseded`.
