# Failure Semantics

Canonical requirement: `docs/spec/rfc-001/05_CORE_REQUIREMENTS.md`.

## Fail-fast rule

If a skill cannot uphold its declared guarantees, it must fail loudly.

## Non-negotiables

- No partial success presented as success.
- No claiming completion after validation failure.
