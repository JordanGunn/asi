# Claims and Evidence Matrix

This document classifies ASI governance claims and binds each claim to required evidence.

## Claim Tiers

- `construction`: true by architecture and documented invariants.
- `verification`: true when explicit checks and review evidence pass.
- `empirical`: supported by measurements in scoped conditions.

## Evidence Requirements by Tier

| Tier | Required evidence | Promotion rule |
| --- | --- | --- |
| `construction` | Source mapping to design/spec docs and implementation invariants | Remains non-operational unless referenced by compliance controls |
| `verification` | Passing checklist outputs and required evidence package | Failing checks invalidate the claim for the reviewed surface |
| `empirical` | Reproducible experiment artifacts with caveats | `MUST NOT` become normative without corresponding design/spec updates |

## Claims Matrix

| Claim ID | Claim statement | Tier | Primary source docs | Required evidence | Disconfirming condition | Confidence note |
| --- | --- | --- | --- | --- | --- | --- |
| C-001 | Skill scope loading is deterministic when `init` and canonical references are used. | `construction` | `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md`, `docs/design/specs/references/05_CANON.md`, `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md` | Reference tree plus deterministic `init` output shape | `init` output ordering differs for equivalent input | High within compliant wrappers |
| C-002 | Deterministic execution authority resides at the CLI boundary. | `construction` | `docs/design/specs/scripts/03_CLI_BOUNDARY.md`, `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md` | Wrapper command traces showing CLI delegation | Wrapper embeds behavior that bypasses CLI boundary | High when wrapper compliance holds |
| C-003 | Active schema drift is constrained by CLI-owned schema/template authority. | `construction` | `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`, `docs/design/specs/skillmd/02_FRONTMATTER.md`, `docs/implementation/01_IMPLEMENTATION_INVARIANTS.md` | `schema` output sample and asset audit report | Active schemas/templates exist as skill assets | High for ASI V2-compliant skills |
| C-004 | Cross-platform wrapper invocation remains consistent across shell and PowerShell surfaces. | `verification` | `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`, `docs/design/principles/10_PORTABILITY.md`, `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md` | `help` output parity, command probe report, review checklist pass | Missing command or behavior divergence between wrappers | Medium-high per reviewed release |
| C-005 | Migration cutovers can be audited and rolled back with explicit gates. | `verification` | `docs/implementation/05_LEGACY_MIGRATION_PLAYBOOK.md`, `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md` | Phase entry/exit evidence and rollback verification records | Phase exits without required evidence or rollback path | Medium-high for governed migrations |
| C-006 | Consolidated references + deterministic init improve context efficiency in tested scenarios. | `empirical` | `docs/implementation/03_BENCHMARK_RATIONALE.md` | `.observations/results/02`, `04`, `05` artifacts with caveats | Re-run under protocol shows non-confirming results | Directional, workload/model dependent |

## Claim Governance Rules

- All new governance benefit claims `MUST` be added to this matrix before being used in implementation guidance.
- Each claim row `MUST` include a disconfirming condition.
- Claims with tier `empirical` `MUST` include caveat-aware provenance.
- Normative requirements `MUST` originate from design/spec sources, not empirical claim rows.
