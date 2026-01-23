# ASI Skills (`asi-*`)

The `asi-*` skills are the reference implementation of the ASI “design → plan → execute” pipeline.

They exist to make agent work reviewable and controllable:

- **Design is captured in an artifact** (not implied in chat)
- **Plans are decomposed into explicit tasks** (not “we’ll just start coding”)
- **Execution happens under a gate** with traceability and receipts

## Quick map

- **`asi-kickoff/`**
  - **What it does**
    - Produces a high-level `KICKOFF.md` (plus `QUESTIONS.md` and scaffold metadata) for a new skill.
  - **What it’s for**
    - Turning an idea into a *reviewable design artifact* that separates deterministic mechanisms from judgment.
  - **What it does not do**
    - No implementation.
  - **Primary output**
    - `.asi/kickoff/KICKOFF.md`

- **`asi-plan/`**
  - **What it does**
    - Converts an **approved** `KICKOFF.md` into `PLAN.md` + `TODO.md`.
  - **What it’s for**
    - Bridging design intent into sequenced, traceable work without writing code.
  - **What it does not do**
    - No implementation.
  - **Primary outputs**
    - `.asi/plan/PLAN.md`
    - `.asi/plan/TODO.md`

- **`asi-exec/`**
  - **What it does**
    - Executes tasks from an **approved** `PLAN.md`, updating `TODO.md` status and producing an execution receipt.
  - **What it’s for**
    - Controlled implementation: one task at a time, with drift checks and an auditable trail.
  - **What it does not do**
    - No planning, no kickoff.
  - **Primary output**
    - `.asi/exec/RECEIPT.md`

## The pipeline (and the gate)

```text
asi-kickoff → asi-plan → asi-exec
     │             │          │
     ▼             ▼          ▼
KICKOFF.md    PLAN.md     Implementation
QUESTIONS.md  TODO.md     RECEIPT.md
```

The intended invariant is simple:

- **No `asi-plan` without an approved `KICKOFF.md`.**
- **No `asi-exec` without an approved `PLAN.md`.**
- **Only `asi-exec` is authorized to implement.**

## When to use which

- Use `asi-kickoff` when you’re not ready to commit to an approach yet, but you *can* describe:
  - The skill’s purpose
  - What can be made deterministic
  - What requires judgment / human gating

- Use `asi-plan` when the design is agreed on and you want a concrete, reviewable breakdown into tasks.

- Use `asi-exec` when you’re ready to implement in a controlled way, with traceability and receipts.

## How to run them

In this repo, each skill is also exposed as a Windsurf workflow:

- `.windsurf/workflows/asi-kickoff.md`
- `.windsurf/workflows/asi-plan.md`
- `.windsurf/workflows/asi-exec.md`

Each workflow delegates to its corresponding manifest:

- `skills/asi/asi-kickoff/SKILL.md`
- `skills/asi/asi-plan/SKILL.md`
- `skills/asi/asi-exec/SKILL.md`

## Where the authoritative behavior lives

For each skill:

- Start at `SKILL.md` (manifest, artifacts, constraints)
- Then read `references/01_SUMMARY.md` (plain-English behavior)
- Then `references/06_PROCEDURE.md` (step-by-step contract)

If you’re extending or auditing the skills, treat `references/` as the source of truth for what the skill is allowed to do.
