---
description: Reasoning contracts for derived arguments used during compilation.
index:
  - Contract Surface
  - Derived Arguments
---

# Contracts

## Contract Surface

The deterministic inputs are:

- `.prompt/active.yaml` (read-only)
- optional `--dry-run` flag (only when explicitly requested)

The deterministic output is:

- `.prompt/PROMPT.md`

## Derived Arguments

This skill has a narrow reasoning contract:

- The agent MUST NOT invent or infer `--dry-run`; it is used only when explicitly requested by the user.
- Any subjective polishing MUST be constrained to editing `.prompt/PROMPT.md` and MUST NOT introduce new requirements not present in `.prompt/active.yaml`.
