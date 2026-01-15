# Required artifacts

A contract-first skill should ship with these artifacts:

- **JSON Schemas** for contracts (strict, explicit, and versioned).
- **Templates and examples** as assets to show valid inputs and expected outputs.
- **Receipts/ledgers** emitted on every run, split into:
  - **Plan**: contract selection, derived parameters, scope, and intended execution.
  - **Results**: executed commands, outputs, validation status, and failures.

Receipts should be deterministic and machine-parseable (JSON or line-delimited text), with stable key ordering when serialized.
