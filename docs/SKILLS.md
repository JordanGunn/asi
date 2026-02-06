# ASI Skills

This repository includes reference skills that help design, plan, and implement skills using the principles defined in ASI.

---

## TL;DR: How to Invoke

```text
/asi-onboard   → "(Optional, recommended) Help me build context on this repo/topic"
/asi-creator   → "Create an ASI-compliant skill for X (interactive next/suggest/apply loop)"
```

That's it. The skills enforce ASI principles automatically.

---

## Skill Design Pipeline

The `asi-*` skills implement a deterministic workflow:

```text
asi-onboard (optional) → asi-creator
        │                │
        ▼                ▼
   NOTES.md        state.json + ask_sets + decisions.log.jsonl + receipts
   SOURCES.md
```

## Pipeline Guarantees

| Stage | Artifact | Guarantee |
| ----- | -------- | --------- |
| **asi-onboard** | `NOTES.md`, `SOURCES.md` | Context capture only. No kickoff/plan/exec artifacts. |
| **asi-creator** | `state.json`, `ask_sets/*.json`, `decisions.log.jsonl`, `receipts/*.json` | Session-loop entrypoint for skill creation. Uses explicit user-confirmed decisions and deterministic validation. |

## Why This Matters

Most agent failures stem from premature action—jumping to code before understanding scope, silently drifting from requirements, or making decisions that should have been human-gated.

This pipeline enforces **deterministic progression**:

- **Context before decision** — Surface ambiguity early, not during implementation
- **Constrained looping** — Every mutation passes schema + validation gates
- **Receipts and logs** — Decisions are append-only and replayable

## Available Skills

### asi-onboard

Establishes disk-backed repo context by reading ASI documentation entrypoints and recording a scoped context digest.

- **Purpose**: Build reusable, resumable context without creating planning artifacts.
- **Output**: `.asi/onboard/NOTES.md`, `.asi/onboard/SOURCES.md`
- **Does not**: Kickoff, plan, or implement.
- **Required?**: No. `asi-creator` does not require onboarding artifacts.

### asi-creator

Unified interactive skill-creation entrypoint.

- **Purpose**: Create ASI-compliant skills with deterministic governance and explicit user-confirmed decisions.
- **Output**: `.asi/creator/state.json`, `.asi/creator/ask_sets/*.json`, `.asi/creator/decisions.log.jsonl`, `.asi/creator/receipts/*.json`
- **Does not**: Serve as a general project planning skill.

## When to Use Which

- Use **`asi-onboard`** when you want to build context (docs/spec discovery) without creating planning artifacts (recommended, not required).
- Use **`asi-creator`** when you want to create or evolve an ASI-compliant skill with deterministic governance.
