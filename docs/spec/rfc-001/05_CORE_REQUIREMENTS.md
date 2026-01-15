# Core requirements

## R1. Skills are the only entry point to capability

An ASI implementation **MUST** define skills as the sole supported interaction surface for capability that can change state (including persistent stores, memory backends, files, or external systems).

An agent **MUST NOT** bypass skills to invoke capability ad-hoc “because it seems relevant”.

## R1.1. Skill invocation favors a single natural-language prompt

To preserve the abstraction that agentic tooling provides (natural language as the interface), an ASI skill **SHOULD** be invokable through whatever syntax the hosting agentic tool assigns, and **SHOULD** accept a single user prompt as its primary argument.

An ASI skill **MAY** also accept additional structured parameters when provided by the hosting environment. When present, these parameters **MUST** be treated as explicit scope and execution controls: they **MUST** be reportable and they **MUST NOT** bypass determinism-before-reasoning requirements.

Derived parameters (scope, filters, patterns, targets) **MAY** be produced during execution, but they **MUST** be made explicit and reportable, and they **MUST NOT** bypass determinism-before-reasoning requirements.

If a skill derives parameters from natural language, it **MUST** declare a reasoning contract (including the explicit “no reasoning contract exists” case) that defines the allowed derivations and reporting expectations.

## R2. Determinism before reasoning

An agent operating under ASI **MUST** apply deterministic surface reduction before reasoning over a corpus, workspace, or other broad surface.

Reasoning **MUST NOT** be used to compensate for missing deterministic outputs. If something required is missing, the system **MUST** return to deterministic discovery, narrowing, or execution rather than “explaining around” gaps.

## R3. Passive means passive

An ASI implementation **MUST** treat passive behavior as strict:

- Systems **MAY** observe, detect drift, and report.
- Systems **MUST NOT** auto-repair, auto-run maintenance, or mutate state without explicit user intent.
- Systems **MUST NOT** perform background mutation or “silent help”.

## R4. Capability does not imply behavior

Exposed tools and available state **MUST NOT** be treated as proof of usage, awareness, or correctness.

Any claim that a tool, store, or skill affected outcome **MUST** be supported by explicit observability (see R8).

## R5. Failure is better than ambiguity

If a skill cannot uphold its declared guarantees, it **MUST** fail loudly.

An ASI implementation **MUST NOT**:

- silently degrade behavior
- silently widen scope
- partially succeed while presenting success

## R6. Schema enforcement and validity

If a skill writes state that is declared to follow a schema or template, the written state **MUST** be valid under that schema/template at the end of execution.

If schema validation is part of the skill’s contract, validation **MUST** be deterministic and reportable.

## R7. Replayability and derived state

Skills **SHOULD** be idempotent or safely re-runnable.

If persistent state exists, the system **SHOULD** prefer derived state that can be deleted and rebuilt deterministically from canonical sources. Agent-derived metadata, when present, **MUST** be explicitly marked as non-canonical and removable without loss of truth.

## R8. Observability and trust

ASI requires reporting sufficient to judge behavior fairly.

At minimum, a skill execution **MUST** report:

- the effective scope (what was considered in-bounds)
- what was read (inputs consulted)
- what was written or changed (mutation surface)
- validation status (pass/fail) for declared artifacts/invariants
