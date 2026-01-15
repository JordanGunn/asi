# Examples (illustrative, non-prescriptive)

- **Example: wrapping different backends under one skill contract**
  - The agent supplies explicit scope inputs (what is in-bounds).
  - The skill performs deterministic surface reduction before any broad interpretation.
  - Any mutation is explicit and attributable; failure is loud if guarantees cannot be met.

- **Example: swapping MCP servers without changing the contract**
  - The skill contract (inputs, guarantees, prohibitions, observability, failure) remains stable.
  - The MCP implementation may change (different server, different persistence), but the agent-facing behavior does not depend on backend identity.
