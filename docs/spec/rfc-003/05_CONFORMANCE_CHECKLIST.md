# Conformance checklist

Use this as an evaluation rubric for skills and for an ASI layer as a whole.

## Governance and entry points

- [ ] Stateful capability is accessed only through skills.
- [ ] Skill contracts are explicit about inputs, guarantees, prohibitions, and failure semantics.
- [ ] Skill invocation uses a single user prompt as the primary argument (preferred).

## Determinism before reasoning

- [ ] A deterministic discovery phase defines the universe of inputs.
- [ ] Narrowing is deterministic and read-only.
- [ ] Reasoning is constrained to the deterministically surfaced scope.
- [ ] Reasoning is not used to “explain around” missing deterministic outputs.

## Passive behavior

- [ ] The system only observes and reports without explicit intent.
- [ ] No auto-repair, background mutation, or silent “help”.

## Validation and artifacts

- [ ] Skills declare artifacts (when applicable).
- [ ] Validation is a hard gate for completion.
- [ ] Schema/template constraints are validated when declared.

## Observability

- [ ] Effective scope is reported (what was considered in-bounds).
- [ ] What was read is attributable and auditable.
- [ ] What was written or changed is attributable and auditable.
- [ ] Validation status is reported in a way that cannot be ignored.
