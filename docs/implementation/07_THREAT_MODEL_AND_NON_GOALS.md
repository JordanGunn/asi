# Threat Model and Non-Goals

This document defines the governance threats ASI implementation controls are intended to address, and the explicit limits of those controls.

## System Boundary

Governed components:

- Agent behavior through skill contracts.
- Wrapper interfaces (`skill.sh`, `skill.ps1`).
- Agent-owned CLI deterministic boundary.
- Canonical references and optional router.
- CLI-emitted schemas/templates.
- Validation/checkpoint and review artifacts.

## Threat Classes

- T-001: Scope inflation through ad hoc or implicit reference loading.
- T-002: Silent execution/mutation without explicit gate checks.
- T-003: Schema or template drift between declared and executed contracts.
- T-004: Cross-platform behavior divergence across wrappers.
- T-005: Audit trail erosion (missing evidence, unclear failure semantics).

## Control Mapping

| Threat ID | Threat description | Control(s) | Detection signal | Residual risk | Linked docs |
| --- | --- | --- | --- | --- | --- |
| T-001 | Scope expands beyond intended reference surface. | Canonical reference set, deterministic `init`, optional router constraints | `init` output or reference tree differs from canonical/routed surface | Intent ambiguity can still cause correct-but-broad scope | `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md`, `docs/design/specs/references/05_CANON.md`, `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md` |
| T-002 | Execution happens without explicit governance boundary. | CLI boundary ownership, wrapper command contract, read-only validate gates | Wrapper trace shows non-CLI behavior, missing checks, or uncontrolled side effects | CLI defects still possible; ASI governs process, not all implementation bugs | `docs/design/specs/scripts/03_CLI_BOUNDARY.md`, `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`, `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md` |
| T-003 | Schema contracts drift from active execution shape. | CLI-emitted schema/template authority, asset restrictions | Active schema/template files found in assets or schema proxy mismatch | Transitional legacy paths can increase drift risk if poorly marked | `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`, `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md` |
| T-004 | Wrapper behavior differs by platform. | Required command parity and portability controls | `help` diff or command probe mismatch between shell and PowerShell wrappers | Runtime shell differences may still affect edge execution details | `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`, `docs/design/principles/10_PORTABILITY.md` |
| T-005 | Governance decisions are not auditable post hoc. | Required evidence package, checklist outputs, migration receipts | Missing review evidence artifacts or ambiguous failure logs | Human review quality variance can reduce audit quality | `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md`, `docs/implementation/05_LEGACY_MIGRATION_PLAYBOOK.md` |

## Non-Goals

- ASI governance is not a runtime security sandbox.
- ASI governance is not a correctness oracle for domain/business logic outcomes.
- ASI governance does not guarantee universal token/context savings across all tasks or model tiers.
- ASI governance does not eliminate the need for human review of policy and product intent.

## Failure Response Posture

- If a control exists and required evidence is missing or failing, classify as non-compliance.
- If no control exists for a recurring threat, classify as governance gap and route to design/spec evolution.
- If control and compliance both hold but outcome quality is poor, classify as model/workload limitation and track as empirical follow-up.
