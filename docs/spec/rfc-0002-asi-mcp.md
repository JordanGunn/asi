# RFC-0002: ASI + MCP (Separation of Concerns)

## Status

Draft, v0.1

## Abstract

This document defines how ASI (governance) relates to MCP (capability/persistence/tool execution). ASI constrains behavior; MCP provides mechanisms. The agent interprets and chooses actions within ASI rules.

## MCP’s role (capability, not policy)

MCP provides a way to expose capabilities such as:

- tool execution
- persistent stores (including “memory”)
- external integrations

MCP does not, by itself, define:

- when tools should run
- what scope is allowed
- what constitutes safe mutation
- what failure must look like

Those are governance questions, and they belong in ASI.

## ASI’s role (governance, not capability)

ASI defines:

- deterministic surface reduction before reasoning
- skills as policy-gated entry points
- strict passive behavior (observe/report; no auto-action)
- explicit failure semantics and observability requirements

ASI does not define transports, wire protocols, or storage schemas.

## Separation of concerns

| Concern | ASI | MCP | Agent |
| --- | --- | --- | --- |
| Defines allowed behavior | Yes | No | Interprets and follows |
| Provides tools / execution | No | Yes | Chooses invocation |
| Provides persistence | No | Yes (or other backends) | Uses via skills |
| Determines scope | Governs how | Enables access | Selects within constraints |
| Reasoning / judgment | Constrains when/over what | No | Yes |

## Backend-agnosticism

An ASI skill **MAY** be implemented over:

- filesystem tooling
- a persistent store exposed via MCP
- hybrid implementations

Agents and higher-level workflows **MUST NOT** depend on backend details to satisfy ASI requirements. The contract is expressed in skills: inputs, guarantees, prohibitions, and failure semantics.

## Why any MCP server benefits from an ASI layer

When MCP servers “fail expectations”, the common response is to add prompts, tools, or memory. This does not solve the invocation problem.

Adding an ASI layer clarifies:

- what a user can expect to happen
- what will not happen without intent
- what was actually read/changed
- why a failure occurred

This improves trust in the system and fairness in how capabilities are evaluated.

## Examples (illustrative, non-prescriptive)

- **Example: wrapping different backends under one skill contract**
  - The agent supplies explicit scope inputs (what is in-bounds).
  - The skill performs deterministic surface reduction before any broad interpretation.
  - Any mutation is explicit and attributable; failure is loud if guarantees cannot be met.

- **Example: swapping MCP servers without changing the contract**
  - The skill contract (inputs, guarantees, prohibitions, observability, failure) remains stable.
  - The MCP implementation may change (different server, different persistence), but the agent-facing behavior does not depend on backend identity.
