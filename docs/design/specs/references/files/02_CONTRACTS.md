# 02_CONTRACTS.md — Reasoning contracts for derived arguments

**Purpose**:

* Define the reasoning contract surface that bridges natural-language intent to deterministic arguments
* Declare whether contracts exist for this skill, including the explicit absence case

**Contains**:

* Contract schemas (or pointers to schemas in assets)
* Allowed derivations and constraints for agent-provided arguments
* Explicit statement when **no reasoning contracts exist** (a valid contract)

**Constraints**:

* No procedural steps
* No execution logic
* No data payloads beyond short illustrative snippets

## Why this file exists

- Agents must translate natural language into deterministic arguments; contracts make that explicit.
- Schemas/templates/examples define shape; this file defines when and why contracts are required.
- Without it, argument selection becomes implicit and un-auditable.
- “No reasoning contract exists” is itself a valid contract that must be stated explicitly.

> This file is the guardrail for derived arguments and contract-level determinism.
