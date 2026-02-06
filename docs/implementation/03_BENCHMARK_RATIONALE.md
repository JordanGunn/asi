# Benchmark Rationale (Supporting Evidence)

This document summarizes supporting observations from AUx benchmark experiments. These findings inform implementation rationale but do not create normative requirements.

Claim tiering and disconfirmation criteria are maintained in `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`. Measurement comparability rules are defined in `docs/implementation/08_MEASUREMENT_PROTOCOL.md`.

## Evidence Policy

- Normative requirements come from ASI design/spec documentation.
- Benchmark findings are supporting, directional evidence.
- Supporting evidence `MUST NOT` create new normative requirements without corresponding updates in `docs/design/specs/`.

## Method Caveats

| Caveat | Impact on interpretation |
| --- | --- |
| Single vendor/runtime environment | Results may not transfer directly to other agent runtimes. |
| Model-tier sensitivity | Low and medium reasoning tiers show different depth/efficiency tradeoffs. |
| Metric collection differences | Tool call counting methods varied between reports. |
| Task-shape specificity | Cross-cutting auth analysis may not represent all workloads. |

## Findings with Provenance

### F1. CLI schema authority improved context efficiency

- Classification: `supporting`, `directional`
- Observation artifacts:
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/02/COMPARISON.md`
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/02/CONCLUSION.md`
- Reported outcome:
  - Baseline context: 47% (182k)
  - Skill path with fixes: 25% (97.9k)
  - Delta: -22 percentage points, approximately -46% tokens consumed
- Interpretation: CLI schema authority reduced overhead while preserving reported coverage.

### F2. Consolidating references (8 -> 4) reduced low-reasoning overhead

- Classification: `supporting`, `directional`
- Observation artifacts:
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/04/COMPARISON.md`
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/04/CONCLUSION.md`
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/04/b/RESULTS.md`
- Reported outcome:
  - Baseline context: 24% (93k)
  - Skill path post-consolidation: 17% (64k)
  - Delta: -7 percentage points, approximately -31% relative context reduction
- Interpretation: Fewer, focused references reduced navigation burden for low-reasoning runs.

### F3. Consolidation preserved efficiency and increased depth for medium reasoning

- Classification: `supporting`, `directional`, `non-generalizable`
- Observation artifacts:
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/05/COMPARISON.md`
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/05/CONCLUSION.md`
  - `/home/jgodau/work/personal/skills/aux/docs/.observations/results/05/b/RESULTS.md`
- Reported outcome:
  - Baseline context: 47% (182k)
  - Skill path post-consolidation: 30% (117k)
  - Delta: approximately -36% context
  - Files analyzed increased with higher reported analysis depth
- Interpretation: Structured onboarding shifted effort from navigation to deeper analysis in this experimental setup.

## Maintainer Guidance (Non-Normative)

- Keep reference docs focused and bounded.
- Preserve deterministic `init` output as the first onboarding surface.
- Keep CLI schema emission as the active contract source.
- Evaluate both efficiency and output quality in future measurements.
