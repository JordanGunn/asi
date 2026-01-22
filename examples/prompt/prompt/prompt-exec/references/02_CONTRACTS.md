---
description: Reasoning contracts for consent and derived arguments used during execution.
index:
  - Contract Surface
  - Explicit Consent
  - Derived Arguments
---

# Contracts

## Contract Surface

The deterministic inputs are:

- `.prompt/active.yaml`
- optional `--dry-run` flag (only when explicitly requested)

The deterministic outputs are:

- a receipt written under `.prompt/receipts/`
- deletion of `.prompt/active.yaml` after successful execution
- the exact prompt text to be executed

## Explicit Consent

Execution is destructive. Consent must be explicit.

Acceptable consent signals include explicit, unambiguous directives like:

- "Yes, execute it."
- "Run it now."
- "Proceed with execution."

The agent MUST NOT treat implied consent, silence, or ambiguity as consent.

## Derived Arguments

- The agent MUST NOT infer `--dry-run`; it is used only when explicitly requested.
- The agent MUST NOT alter or "clean up" the prompt text; execution uses the prompt exactly as stored.
