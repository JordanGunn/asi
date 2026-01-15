# Failure Semantics

## Fail-fast rule

If a skill cannot uphold its declared guarantees, it must fail loudly.

## Forbidden failure modes

- Silent degradation (“best effort” without saying so).
- Partial success presented as success.
- Continuing after validation failure while claiming completion.

## Why

Failure is better than ambiguity. Partial success is corruption with better PR.

