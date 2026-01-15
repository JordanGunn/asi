# RFC-0001: Agent Skill Interface (ASI)

## Status

Draft, v0.1

## Abstract

Agentic systems often expose capability (tools, memory, skills) without providing a trustworthy contract for **behavior**. ASI (Agent Skill Interface) is a governance layer that defines a strict ordering (determinism before reasoning), a strict passive behavior contract, and explicit failure semantics so that outcomes are auditable and non-magical.

## Problem statement

Users commonly assume that:

- exposed tools will be used automatically
- memory implies recall and awareness
- skills “kick in” when relevant

In practice, agentic systems are silent unless invoked explicitly and correctly. When capability is mistaken for behavior, ecosystems respond by adding prompts, more tools, more memory, or background logic. This does not fix invocation and often reduces trust.

ASI exists to ensure that if something happens, it is explainable and attributable — and if nothing happens, that can still be correct.

## Definitions

- **ASI (Agent Skill Interface):** A behavioral contract that governs how an agent may reason, reduce scope, and mutate state through skills.
- **Agent:** An interpreter that accepts user testimony, performs reasoning, and chooses whether to invoke skills, within ASI rules.
- **Skill:** A policy-gated entry point that provides explicit guarantees and prohibitions for an operation.
- **Deterministic surface reduction:** A measurable, repeatable process that enumerates a universe of inputs and narrows it without guessing.
- **Passive behavior:** The posture that systems may observe and report, but do not act (mutate state) without explicit user intent and explicit invocation.
- **Artifact:** A declared output (files, records, reports) used as a completion signal.
- **Validation:** A deterministic hard gate that proves declared artifacts and invariants hold.

## Core requirements

### R1. Skills are the only entry point to capability

An ASI implementation **MUST** define skills as the sole supported interaction surface for capability that can change state (including persistent stores, memory backends, files, or external systems).

An agent **MUST NOT** bypass skills to invoke capability ad-hoc “because it seems relevant”.

### R1.1. Skill invocation favors a single natural-language prompt

To preserve the abstraction that agentic tooling provides (natural language as the interface), an ASI skill **SHOULD** be invokable through whatever syntax the hosting agentic tool assigns, and **SHOULD** accept a single user prompt as its primary argument.

An ASI skill **MAY** also accept additional structured parameters when provided by the hosting environment. When present, these parameters **MUST** be treated as explicit scope and execution controls: they **MUST** be reportable and they **MUST NOT** bypass determinism-before-reasoning requirements.

Derived parameters (scope, filters, patterns, targets) **MAY** be produced during execution, but they **MUST** be made explicit and reportable, and they **MUST NOT** bypass determinism-before-reasoning requirements.

### R2. Determinism before reasoning

An agent operating under ASI **MUST** apply deterministic surface reduction before reasoning over a corpus, workspace, or other broad surface.

Reasoning **MUST NOT** be used to compensate for missing deterministic outputs. If something required is missing, the system **MUST** return to deterministic discovery, narrowing, or execution rather than “explaining around” gaps.

### R3. Passive means passive

An ASI implementation **MUST** treat passive behavior as strict:

- Systems **MAY** observe, detect drift, and report.
- Systems **MUST NOT** auto-repair, auto-run maintenance, or mutate state without explicit user intent.
- Systems **MUST NOT** perform background mutation or “silent help”.

### R4. Capability does not imply behavior

Exposed tools and available state **MUST NOT** be treated as proof of usage, awareness, or correctness.

Any claim that a tool, store, or skill affected outcome **MUST** be supported by explicit observability (see R8).

### R5. Failure is better than ambiguity

If a skill cannot uphold its declared guarantees, it **MUST** fail loudly.

An ASI implementation **MUST NOT**:

- silently degrade behavior
- silently widen scope
- partially succeed while presenting success

### R6. Schema enforcement and validity

If a skill writes state that is declared to follow a schema or template, the written state **MUST** be valid under that schema/template at the end of execution.

If schema validation is part of the skill’s contract, validation **MUST** be deterministic and reportable.

### R7. Replayability and derived state

Skills **SHOULD** be idempotent or safely re-runnable.

If persistent state exists, the system **SHOULD** prefer derived state that can be deleted and rebuilt deterministically from canonical sources. Agent-derived metadata, when present, **MUST** be explicitly marked as non-canonical and removable without loss of truth.

### R8. Observability and trust

ASI requires reporting sufficient to judge behavior fairly.

At minimum, a skill execution **MUST** report:

- the effective scope (what was considered in-bounds)
- what was read (inputs consulted)
- what was written or changed (mutation surface)
- validation status (pass/fail) for declared artifacts/invariants

## Skill anatomy (normative)

Each ASI skill **MUST** define, at minimum:

- **Purpose:** what the skill is for (and what it is not for)
- **Inputs:** the parameters that determine scope and execution
- **Deterministic guarantees:** what is enumerable, stable, and repeatable
- **Prohibitions:** what the skill must not do (including hidden scope widening)
- **Failure semantics:** what constitutes failure and how it is surfaced

Skills **SHOULD** declare their artifacts and validation gates explicitly.

## Canonical ordering

ASI assumes the following ordering as a mental model:

1. Define the universe (deterministic discovery)
2. Narrow deterministically (deterministic narrowing)
3. Act on the narrowed surface (deterministic execution)
4. Prove it worked (deterministic validation)
5. Think about it (subjective reasoning / interpretation)
6. Record it (human-facing artifacts and summaries)

If a skill includes phases analogous to these, it **MUST** preserve the invariant that subjective reasoning does not precede or substitute for deterministic surface reduction and validation.

## Non-goals

ASI is explicitly not:

- a transport protocol
- a backend or storage design
- a replacement for MCP or agent judgment
- an “always-on mutation engine”

## Rationale (non-normative)

ASI exists to replace illusion with intention: powerful thinkers, not powerful actors. It does not make systems smarter; it makes them trustworthy by constraining scope, sequencing, passivity, and failure.
