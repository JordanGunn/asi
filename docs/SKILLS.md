# ASI Skills

This repository includes reference skills that help design, plan, and implement skills using the principles defined in ASI.

---

## TL;DR: How to Invoke

```text
/asi-kickoff   → "I want to build a skill that does X"
/asi-plan      → "The kickoff is approved, break it into tasks"
/asi-exec      → "Execute the next task from the plan"
```

That's it. The skills enforce ASI principles automatically.

---

## Skill Design Pipeline

The `asi-*` skills implement a three-stage pipeline:

```text
asi-kickoff → asi-plan → asi-exec
     │             │          │
     ▼             ▼          ▼
KICKOFF.md    PLAN.md     Implementation
QUESTIONS.md  TODO.md     RECEIPT.md
```

## Pipeline Guarantees

| Stage | Artifact | Guarantee |
| ----- | -------- | --------- |
| **asi-kickoff** | `KICKOFF.md` | No implementation without explicit design. Deterministic surface mapped. Judgment remainder documented. |
| **asi-plan** | `PLAN.md`, `TODO.md` | No execution without approved plan. Tasks traceable to kickoff. Cascade invalidation if upstream changes. |
| **asi-exec** | Implementation | No uncontrolled implementation. Single-task execution. Auditable receipts. Drift detection. |

## Why This Matters

Most agent failures stem from premature action—jumping to code before understanding scope, silently drifting from requirements, or making decisions that should have been human-gated.

This pipeline enforces **deliberate progression**:

- **Design before planning** — Surface ambiguity early, not during implementation
- **Plan before execution** — Decompose work into traceable, reviewable tasks
- **Execute with receipts** — Every change is logged, every task is checkpointed

## Available Skills

### asi-kickoff

Produces a high-level `KICKOFF.md` (plus `QUESTIONS.md` and scaffold metadata) for a new skill.

- **Purpose**: Turn an idea into a reviewable design artifact that separates deterministic mechanisms from judgment.
- **Output**: `.asi/kickoff/KICKOFF.md`
- **Does not**: Implement anything.

### asi-plan

Converts an **approved** `KICKOFF.md` into `PLAN.md` + `TODO.md`.

- **Purpose**: Bridge design intent into sequenced, traceable work without writing code.
- **Output**: `.asi/plan/PLAN.md`, `.asi/plan/TODO.md`
- **Does not**: Implement anything.

### asi-exec

Executes tasks from an **approved** `PLAN.md`, updating `TODO.md` status and producing an execution receipt.

- **Purpose**: Controlled implementation—one task at a time, with drift checks and an auditable trail.
- **Output**: `.asi/exec/RECEIPT.md`
- **Does not**: Plan or kickoff.

## Pipeline Invariants

- **No `asi-plan` without an approved `KICKOFF.md`.**
- **No `asi-exec` without an approved `PLAN.md`.**
- **Only `asi-exec` is authorized to implement.**

## When to Use Which

- Use **`asi-kickoff`** when you're not ready to commit to an approach yet, but you can describe the skill's purpose, what can be made deterministic, and what requires judgment/human gating.
- Use **`asi-plan`** when the design is agreed on and you want a concrete, reviewable breakdown into tasks.
- Use **`asi-exec`** when you're ready to implement in a controlled way, with traceability and receipts.
