# ASI Skills

This repository includes reference skills that help design, plan, and implement skills using the principles defined in ASI.

---

## TL;DR: How to Invoke

```text
/asi-onboard   → "(Optional, recommended) Help me build context on this repo/topic"
/asi-creator   → "Create an ASI-compliant skill for X (kickoff + plan + controlled execution)"
```

That's it. The skills enforce ASI principles automatically.

---

## Skill Design Pipeline

The `asi-*` skills implement a gated workflow:

```text
asi-onboard (optional) → asi-creator
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
| **asi-creator** | `KICKOFF.md`, `PLAN.md`, `TODO.md`, `RECEIPT.md` | Unified kickoff+plan+exec entrypoint. Must not produce PLAN/TODO until kickoff is approved. Must not execute until plan is approved. |

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
- **Required?**: No. `asi-creator` does not require onboarding artifacts.

### asi-creator

Unified kickoff + planning + controlled execution entrypoint.

- **Purpose**: Create ASI-compliant skills with deterministic governance and explicit gates.
- **Output**: `.asi/creator/kickoff/KICKOFF.md`, `.asi/creator/plan/PLAN.md`, `.asi/creator/plan/TODO.md`, `.asi/creator/exec/RECEIPT.md`
- **Does not**: Serve as a general project planning skill.

## Pipeline Invariants

- **`asi-creator` must not produce PLAN/TODO without an approved `KICKOFF.md`.**
- **`asi-creator` must not execute without an approved `PLAN.md`.**
- **Only `asi-creator` is authorized to implement.**

## When to Use Which

- Use **`asi-onboard`** when you want to build context (docs/spec discovery) without creating planning artifacts (recommended, not required).
- Use **`asi-creator`** when you want to create or evolve an ASI-compliant skill with deterministic governance.
