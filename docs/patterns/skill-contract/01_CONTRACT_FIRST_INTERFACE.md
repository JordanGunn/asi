# Contract-first interface

**Flow:** prompt -> reasoning contract(s) -> deterministic args -> execution.

Contracts are the bridge between natural-language intent and CLI arguments. They act as epistemic guardrails: if a parameter cannot be derived under the contract, it must be reported as missing rather than guessed.

**Minimum contract surface:**

- Inputs: user prompt plus any explicit structured parameters.
- Derived parameters: patterns, scope, filters, targets.
- Rules: how derivation happens, what is allowed, and what must be reported.
