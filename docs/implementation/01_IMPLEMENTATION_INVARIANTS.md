# Implementation Invariants

This document maps ASI implementation invariants to enforcement points, failure behavior, and evidence artifacts.

Normative source of truth remains in `docs/design/specs/` and `docs/design/principles/`.

Claims tiering and required evidence expectations are tracked in `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`.

## I1. Canonical Reference Set

- Requirement: Skills `MUST` use the V2 canonical reference set (`01_SUMMARY.md`, `02_INTENT.md`, `03_POLICIES.md`, `04_PROCEDURE.md`); `00_ROUTER.md` `MAY` exist only when deterministic routing is required.
- Rationale: Canonical references minimize navigation entropy while preserving deterministic scope control.
- Enforceability test: Reference tree inspection confirms canonical files exist and optional router is justified by route logic.
- Spec sources: `docs/design/specs/references/05_CANON.md`, `docs/design/specs/references/files/00_ROUTER.md`.
- Enforcement point: Reference validation and wrapper `init` behavior.
- Failure mode: Increased context overhead, ambiguous routing, weak scope observability.
- Evidence artifact: Deterministic `init` output and reference tree.

## I2. Agent-Owned CLI Boundary

- Requirement: Deterministic execution `MUST` be delegated to an agent-owned CLI boundary.
- Rationale: Centralized deterministic control reduces host-environment drift and policy fragmentation.
- Enforceability test: Wrapper command implementation resolves to CLI invocation paths rather than embedded business logic.
- Spec sources: `docs/design/specs/scripts/03_CLI_BOUNDARY.md`, `docs/design/specs/scripts/06_INSTALLATION.md`.
- Enforcement point: Wrapper command implementation and CLI availability checks.
- Failure mode: Non-reproducible behavior and environment-dependent outcomes.
- Evidence artifact: Wrapper command traces and CLI help/schema output.

## I3. Canonical Wrapper Command Surface

- Requirement: `skill.sh` and `skill.ps1` `MUST` expose equivalent command surfaces: `help`, `init`, `validate`, `schema`, `run`.
- Rationale: Command parity is required for portability and deterministic cross-platform invocation.
- Enforceability test: `help` output diff and command probe show equivalent command availability across both wrappers.
- Spec sources: `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`, `docs/design/principles/10_PORTABILITY.md`.
- Enforcement point: Wrapper scripts and cross-platform validation.
- Failure mode: Platform divergence and non-portable invocation paths.
- Evidence artifact: Wrapper usage output and parity checks.

## I4. CLI-Owned Schemas and Templates

- Requirement: Active schemas/templates `MUST` be emitted or applied by the CLI and `MUST NOT` be stored as active skill assets in ASI V2.
- Rationale: A single schema authority improves type safety and reduces contract drift.
- Enforceability test: `schema` command returns CLI-emitted schema; asset audit confirms no active schemas/templates under skill assets.
- Spec sources: `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`, `docs/design/specs/skillmd/02_FRONTMATTER.md`.
- Enforcement point: `schema` proxy behavior and asset review.
- Failure mode: Schema drift, stale contracts, weak type safety.
- Evidence artifact: `<cli> <skill> --schema` output and asset audit report.

## I5. Deterministic `init` Loads References

- Requirement: `init` `MUST` load references deterministically and `SHOULD` be treated as the primary skill onboarding mechanism.
- Rationale: Deterministic onboarding reduces manual read variance and enforces explicit scope loading.
- Enforceability test: `init` output is single-stream, ordered, and route-consistent for equivalent inputs.
- Spec sources: `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md`, `docs/design/specs/references/files/00_ROUTER.md`.
- Enforcement point: Wrapper `init` implementation.
- Failure mode: Manual file-reading variance and unnecessary context inflation.
- Evidence artifact: Single-stream `init` output with effective scope.
