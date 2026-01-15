# Execution model

- **OS-native scripts** are the top-level entrypoints **within the skill implementation** (e.g., `validate.sh`, `run.sh`).
- **Implementation language is flexible**, but scripts should be thin wrappers that:
  - normalize inputs
  - invoke the implementation
  - emit receipts

This keeps execution auditable and portable without hard-wiring a single runtime.
