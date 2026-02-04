# Installation and Dependency Boundary

The agent-owned CLI is a single abstract dependency shared across one or many skills. This is intentional.

## Advantages

- One installation covers all skills that bind to the CLI.
- Dependency management is centralized and deterministic.
- Skills do not drift by relying on host tools or ad hoc dependencies.
- Updates are controlled and auditable at the CLI boundary.

## Requirements

- Skills must declare the CLI as their execution dependency.
- Wrapper scripts must invoke the CLI rather than direct system tools.
- The CLI version should be discoverable in `help` output or metadata.
