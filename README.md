# ASI (Agent Skill Interface)

This repository contains a publication-grade, agent-followable specification for **Agent Skill Interface (ASI)**: a governance contract that defines **when reasoning is allowed**, **how scope is constructed**, **what may mutate**, and **how failure must surface**.

## What ASI is

ASI is a **behavioral contract** (policy / governance layer) for agentic systems.

It defines:

- deterministic surface reduction before reasoning
- skills as the policy-gated entry point to capability
- skill invocation that favors a single natural-language prompt (with explicit, reportable parameters when structured inputs exist)
- strict passive behavior (observe/report; no silent action)
- auditable state changes and explicit failure semantics

## What ASI is not

ASI is **not**:

- a protocol or transport
- a framework or SDK requirement
- MCP (Model Context Protocol) or a replacement for MCP
- “smart tools” that auto-run in the background

## How to read

1. `docs/manifesto.md`
2. `docs/spec/rfc-0001-asi.md`
3. `docs/spec/rfc-0002-asi-mcp.md`
4. `docs/spec/rfc-0003-conformance.md`
5. `docs/design-principles/00_INDEX.md` (implementation guidance)
6. `docs/examples/` (small illustrations)

If you are implementing or auditing an ASI layer, start with `docs/spec/rfc-0003-conformance.md`.

## Implementation guidance

- Skill authoring conventions: `docs/design/specs/.INDEX.md`
- Copyable templates (RFCs, examples, reference set): `assets/templates/README.md`
- Deterministic repo checks: `scripts/README.md`

## TL;DR

ASI exists to make agentic systems **trustworthy**: determinism before reasoning, skills as policy, passive means passive, and failure is better than ambiguity.
