# Agent-Owned CLI Boundary

Skills bind to an agent-owned CLI that is the deterministic execution boundary. The CLI owns dependencies, policy constraints, and schema emission.

## Requirements

- The CLI bundles required dependencies in a single installation.
- The CLI enforces allowed commands and bounded output.
- The CLI provides canonical help text.
- The CLI provides read-only validation entrypoints (`doctor` or `validate`).

## Guarantees

- Deterministic output ordering for equivalent inputs.
- Bounded output with explicit truncation signals.
- No implicit reliance on host tools outside the CLI boundary.
