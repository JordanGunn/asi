# 02_INTENT.md — Intent contract and schema linkage

**Purpose**:

* Define how natural-language intent is compiled into deterministic parameters.
* Declare the schema source of truth for the plan or intent contract.

**Contains**:

* Description of allowed derivations and constraints for agent-provided arguments.
* Explicit schema pointer (for example: `<cli> <skill> --schema`).
* Guardrails for scope narrowing and parameter derivation.

**Constraints**:

* No procedural steps.
* No execution logic.
* No large data payloads beyond short illustrative snippets.

This file defines the contract boundary for derived arguments and makes the schema surface explicit.
