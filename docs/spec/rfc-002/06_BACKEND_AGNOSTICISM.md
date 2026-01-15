# Backend-agnosticism

An ASI skill **MAY** be implemented over:

- filesystem tooling
- a persistent store exposed via MCP
- hybrid implementations

Agents and higher-level workflows **MUST NOT** depend on backend details to satisfy ASI requirements. The contract is expressed in skills: inputs, guarantees, prohibitions, and failure semantics.
