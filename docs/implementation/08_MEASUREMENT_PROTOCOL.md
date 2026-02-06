# Measurement Protocol

This protocol standardizes measurement for ASI governance outcomes so empirical claims remain comparable and reproducible.

## Primary KPIs

- Context consumption: tokens/context percentage consumed per run.
- Coverage completeness: required components discovered for the task class.
- Review effort: time/check steps needed to verify compliance evidence.
- Compliance failure rate: proportion of runs failing blocking checks.
- Rework/regression rate: follow-up corrections caused by governance/control failures.

## Experiment Contract

Each run record `MUST` include:

- Task class and prompt shape.
- Model identifier and reasoning tier.
- Runtime/tooling environment.
- Skill configuration state.
- Metric counting method (especially tool-call treatment).
- Artifact paths for raw results, comparison, and conclusions.

## Comparability Rules

Two runs are comparable only if all conditions hold:

- Same task class and materially equivalent prompt intent.
- Same model family/tier (or explicitly declared cross-tier comparison).
- Same environment/runtime constraints or explicit normalization notes.
- Same metric definitions and counting method.
- Complete artifact trail for both runs.

Invalid comparison triggers:

- Missing metadata fields.
- Inconsistent tool-call counting approach without normalization.
- Substantially different task surfaces treated as equivalent.

## Result Classification

- `confirming`: results support expected directional effect with no major caveat escalation.
- `mixed`: some KPIs improve while others regress or become inconclusive.
- `non-confirming`: expected effect is not observed under protocol-comparable conditions.

## Evidence Retention Requirements

Each measured run `MUST` retain:

- Raw run outputs.
- Comparison table.
- Conclusion summary.
- Metadata manifest (date, model, reasoning tier, environment, artifacts).

## Promotion Rule

- Empirical results can justify rationale updates immediately in implementation docs.
- Empirical results `MUST NOT` create or alter normative requirements without explicit updates in `docs/design/specs/`.

## Minimal Run Checklist

- [ ] Task class declared.
- [ ] Model and reasoning tier declared.
- [ ] Environment/runtime declared.
- [ ] KPI definitions declared.
- [ ] Counting methodology declared.
- [ ] Raw artifacts retained.
- [ ] Comparison and conclusion artifacts retained.
- [ ] Result classification assigned (`confirming`, `mixed`, `non-confirming`).
