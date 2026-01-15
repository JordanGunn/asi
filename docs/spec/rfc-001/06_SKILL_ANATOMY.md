# Skill anatomy (normative)

Each ASI skill **MUST** define, at minimum:

- **Purpose:** what the skill is for (and what it is not for)
- **Inputs:** the parameters that determine scope and execution
- **Deterministic guarantees:** what is enumerable, stable, and repeatable
- **Prohibitions:** what the skill must not do (including hidden scope widening)
- **Failure semantics:** what constitutes failure and how it is surfaced

Skills **SHOULD** declare their artifacts and validation gates explicitly.
