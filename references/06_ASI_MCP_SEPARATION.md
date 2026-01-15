# ASI vs MCP Separation

## Mental model

- ASI governs behavior (policy).
- MCP provides capability and persistence (mechanism).
- Agents interpret user testimony and choose actions within ASI constraints.

## Why it matters

When MCP servers “don’t work”, the root issue is often invocation and expectations, not missing capability. ASI prevents capability from being mistaken for behavior by making scope, sequencing, passivity, and failure explicit.

## Implication

Any MCP-backed capability is easier to trust when wrapped in an ASI skill contract (inputs, guarantees, prohibitions, observability, and failure semantics).

