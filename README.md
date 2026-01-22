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

## Skill Design Pipeline

This repository includes a three-stage pipeline for designing ASI-compliant skills:

```
asi-kickoff → asi-plan → asi-exec
     │             │          │
     ▼             ▼          ▼
KICKOFF.md    PLAN.md     Implementation
QUESTIONS.md  TODO.md     RECEIPT.md
```

### What the pipeline guarantees

| Stage | Artifact | Guarantee |
| ----- | -------- | --------- |
| **asi-kickoff** | `KICKOFF.md` | No implementation without explicit design. Deterministic surface mapped. Judgment remainder documented. |
| **asi-plan** | `PLAN.md`, `TODO.md` | No execution without approved plan. Tasks traceable to kickoff. Cascade invalidation if upstream changes. |
| **asi-exec** | Implementation | No uncontrolled implementation. Single-task execution. Auditable receipts. Drift detection. |

### Why this matters

Most agent failures stem from premature action—jumping to code before understanding scope, silently drifting from requirements, or making decisions that should have been human-gated.

This pipeline enforces **deliberate progression**:

- **Design before planning** — Surface ambiguity early, not during implementation
- **Plan before execution** — Decompose work into traceable, reviewable tasks
- **Execute with receipts** — Every change is logged, every task is checkpointed

The skills live in `skills/` and are themselves ASI-compliant. Use them to build more skills.

---

## Recommended reading path

This table of contents is a suggested order for first-time readers.

1. `docs/manifesto/.INDEX.md` — Narrative framing for ASI
2. `docs/design/model/.INDEX.md` — Execution model and boundary semantics
3. `docs/design/principles/.INDEX.md` — Core design principles
4. `docs/design/specs/.INDEX.md` — Canonical specifications for skill files
5. `examples/` — Small illustrations

When implementing or auditing an ASI layer, start with `docs/design/specs/.INDEX.md`.

## For LLMs and Agents

Fetch the `llms.txt` file for structured access to this documentation:

```text
https://raw.githubusercontent.com/JordanGunn/asi/refs/heads/master/llms.txt
```

**Suggested prompt:**

> Fetch https://raw.githubusercontent.com/JordanGunn/asi/refs/heads/master/llms.txt and use the linked documents to learn about ASI (Agent Skill Interface). Summarize the core principles and how skills should be structured.

## TL;DR

ASI exists to make agentic systems **trustworthy**: determinism before reasoning, skills as policy, passive means passive, and failure is better than ambiguity.
