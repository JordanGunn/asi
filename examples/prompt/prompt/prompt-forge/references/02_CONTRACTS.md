---
description: Reasoning contracts for translating intent into deterministic artifact updates.
index:
  - Contract Surface
  - Derived Arguments
  - Explicit Consent
---

# Contracts

## Contract Surface

This skill translates natural-language intent into a single on-disk artifact at `.prompt/active.yaml`.

The contract surface is the artifact itself:

- `intent.objective` (string)
- `intent.constraints` (string[])
- `intent.assumptions` (string[])
- `intent.open_questions` (string[])
- `prompt` (string)
- `status` (`drafting` or `ready`)

## Derived Arguments

The agent may derive *artifact field values* from the conversation, but must keep derivations auditable:

- Derived fields MUST be reflected back to the user as a proposed update before persisting.
- Derived fields MUST NOT introduce new requirements not stated or confirmed by the user.

## Explicit Consent

The only state transition that requires explicit confirmation is `status: ready`.

- The agent MUST NOT mark the artifact `ready` unless the user explicitly confirms readiness.
- If open questions remain, the agent MUST NOT mark the artifact ready.
