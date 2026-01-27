# ASI Skills

This repository includes reference skills that help design, plan, and implement skills using the principles defined in ASI.

---

## TL;DR: How to Invoke

```text
/asi-onboard   → "(Optional, recommended) Help me build context on this repo/topic"
/asi-plan      → "Plan the implementation for X" (includes kickoff phase if needed)
/asi-kickoff   → "I only want to do the kickoff phase for X" (optional/legacy)
/asi-exec      → "Execute the next task from the plan"
```

That's it. The skills enforce ASI principles automatically.

---

## Skill Design Pipeline

The `asi-*` skills implement a gated workflow:

```text
asi-onboard (optional) → asi-plan → asi-exec
        │                │          │
        ▼                ▼          ▼
   NOTES.md          KICKOFF.md  Implementation
   SOURCES.md        QUESTIONS.md RECEIPT.md
                         │
                         ▼
                      PLAN.md
                      TODO.md
```

## Pipeline Guarantees

| Stage | Artifact | Guarantee |
| ----- | -------- | --------- |
| **asi-onboard** | `NOTES.md`, `SOURCES.md` | Context capture only. No kickoff/plan/exec artifacts. |
| **asi-kickoff** | `KICKOFF.md` | No implementation without explicit design. Deterministic surface mapped. Judgment remainder documented. |
| **asi-plan** | `KICKOFF.md`, `PLAN.md`, `TODO.md` | Unified kickoff+plan entrypoint. Must not produce PLAN/TODO until kickoff is approved. Tasks traceable to kickoff. Cascade invalidation if upstream changes. |
| **asi-exec** | Implementation | No uncontrolled implementation. Single-task execution. Auditable receipts. Drift detection. |

## Why This Matters

Most agent failures stem from premature action—jumping to code before understanding scope, silently drifting from requirements, or making decisions that should have been human-gated.

This pipeline enforces **deliberate progression**:

- **Design before planning** — Surface ambiguity early, not during implementation
- **Plan before execution** — Decompose work into traceable, reviewable tasks
- **Execute with receipts** — Every change is logged, every task is checkpointed

## Available Skills

### asi-onboard

Establishes disk-backed repo context by reading ASI documentation entrypoints and recording a scoped context digest.

- **Purpose**: Build reusable, resumable context without creating planning artifacts.
- **Output**: `.asi/onboard/NOTES.md`, `.asi/onboard/SOURCES.md`
- **Does not**: Kickoff, plan, or implement.
- **Required?**: No. `asi-plan` does not require onboarding artifacts.

### asi-kickoff

Produces a high-level `KICKOFF.md` (plus `QUESTIONS.md` and scaffold metadata) for a new skill.

- **Purpose**: Turn an idea into a reviewable design artifact that separates deterministic mechanisms from judgment.
- **Output**: `.asi/kickoff/KICKOFF.md`
- **Does not**: Implement anything.

### asi-plan

Unified kickoff + planning entrypoint.

- **Purpose**: Converge on kickoff + plan artifacts in a single interface.
- **Output**: `.asi/plan/PLAN.md`, `.asi/plan/TODO.md`
- **Does not**: Implement anything.

### asi-exec

Executes tasks from an **approved** `PLAN.md`, updating `TODO.md` status and producing an execution receipt.

- **Purpose**: Controlled implementation—one task at a time, with drift checks and an auditable trail.
- **Output**: `.asi/exec/RECEIPT.md`
- **Does not**: Plan or kickoff.

## Pipeline Invariants

- **`asi-plan` must not produce PLAN/TODO without an approved `KICKOFF.md`.**
- **No `asi-exec` without an approved `PLAN.md`.**
- **Only `asi-exec` is authorized to implement.**

## When to Use Which

- Use **`asi-onboard`** when you want to build context (docs/spec discovery) without creating planning artifacts (recommended, not required).
- Use **`asi-plan`** when you want to converge on kickoff + plan artifacts (it will run kickoff first if needed).
- Use **`asi-kickoff`** when you explicitly want the kickoff phase only (optional/legacy entrypoint).
- Use **`asi-exec`** when you're ready to implement in a controlled way, with traceability and receipts.
