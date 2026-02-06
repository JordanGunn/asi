# ASI Skills (`asi-*`)

The `asi-*` skills are the reference implementation of the ASI “context → design/plan → execute” workflow.

They exist to make agent work reviewable and controllable:

- **Design is captured in an artifact** (not implied in chat)
- **Plans are decomposed into explicit tasks** (not “we’ll just start coding”)
- **Execution happens under a gate** with traceability and receipts

## Quick map

- **`asi-onboard/`**
  - **What it does**
    - Establishes disk-backed repo context by reading ASI documentation entrypoints and recording a scoped context digest.
  - **What it’s for**
    - Building reusable, resumable context without producing planning artifacts.
  - **What it does not do**
    - No kickoff, no plan, no implementation.
  - **Primary outputs**
    - `.asi/onboard/NOTES.md`
    - `.asi/onboard/SOURCES.md`

- **`asi-creator/`**
  - **What it does**
    - Interactive `next -> suggest -> apply` loop for ASI skill creation.
  - **What it’s for**
    - Building ASI-compliant skills with deterministic governance and explicit user confirmation.
  - **What it does not do**
    - It is not a general project planning skill.
  - **Primary outputs**
    - `.asi/creator/state.json`
    - `.asi/creator/ask_sets/*.json`
    - `.asi/creator/decisions.log.jsonl`
    - `.asi/creator/receipts/*.json`

## The pipeline (and the gate)

```text
asi-onboard (optional) → asi-creator
        │                │
        ▼                ▼
   NOTES.md      state + ask_sets + logs + receipts
```

The intended invariant is simple:

- **`asi-creator` must not mutate decisions without explicit confirmation.**
- **`asi-creator` must validate all interactive inputs against CLI-emitted schemas.**
- **`asi-creator` must persist append-only decision evidence for auditability.**

## When to use which

- Use `asi-onboard` when you want to build context (docs/spec discovery) without creating planning artifacts (recommended, not required).

- Use `asi-creator` when you want to create or evolve an ASI-compliant skill through deterministic, schema-driven interaction loops.

## How to run them

In this repo, each skill is also exposed as a Windsurf workflow:

- `.windsurf/workflows/asi-onboard.md`
- `.windsurf/workflows/asi-creator.md`

Each workflow delegates to its corresponding manifest:

- `skills/asi-onboard/SKILL.md`
- `skills/asi-creator/SKILL.md`

## Where the authoritative behavior lives

For each skill:

- Start at `SKILL.md` (manifest, artifacts, constraints)
- Then read `references/01_SUMMARY.md` (plain-English behavior)
- Then `references/04_PROCEDURE.md` (step-by-step contract)

If you’re extending or auditing the skills, treat `references/` as the source of truth for what the skill is allowed to do.

In ASI V2, wrapper scripts must expose `help`, `init`, `validate`, `schema`, and `run`, and delegate execution to the agent-owned CLI.
