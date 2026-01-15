# Conformance Checklist

## Entry points

- [ ] Capability that can change state is accessed only through skills.
- [ ] Skills define explicit inputs, guarantees, prohibitions, and failure semantics.
- [ ] Skill invocation uses a single user prompt as the primary argument (preferred).

## Determinism before reasoning

- [ ] Discovery defines the complete input universe deterministically.
- [ ] Narrowing reduces scope deterministically and read-only.
- [ ] Reasoning is constrained to the deterministically surfaced scope.

## Passive behavior

- [ ] Observe/report is allowed without intent.
- [ ] No background mutation or auto-repair occurs.

## Validation and artifacts

- [ ] Declared artifacts exist on success.
- [ ] Validation is a hard gate when artifacts/invariants are declared.
- [ ] Declared schemas/templates are validated when state is written.

## Observability

- [ ] Effective scope is reported (what was considered in-bounds).
- [ ] What was read is auditable.
- [ ] What was written or changed is auditable.
- [ ] Validation status is reported.
