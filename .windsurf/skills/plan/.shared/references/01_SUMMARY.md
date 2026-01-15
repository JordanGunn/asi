---
description: What this skill is and is not.
index:
  - What It Does
  - What Problems It Solves
  - What It Is Not
  - Key Invariant
  - Artifact Location
---

# Summary

The **plan** skillset manages bounded work units with structured plans stored in `.plan/`.

## What It Does

- Scaffolds and populates plan structures (plan-create)
- Executes tasks by performing actual work (plan-exec)
- Displays progress via CLI (plan-status)
- Reviews completed plans (plan-review)

## What Problems It Solves

- Breaks large work into trackable units
- Ensures execution means implementation (not description)
- Creates reviewable artifacts for handoff
- Tracks progress with frontmatter status

## What It Is Not

- Not a to-do list (use task skillset for that)
- Not for trivial changes (overhead not justified)
- Not purely subjective (CLI provides deterministic queries)

## Key Invariant

**Execution means implementation.** When plan-exec runs, it performs actual work — writes real code, creates real files. Filling Output with descriptions is a failure mode.

## Artifact Location

All artifacts stored in `.plan/<N>/`:

- `plan.md` — Root plan with objective and success criteria
- `<letter>/index.md` — Sub-plan index
- `<letter>/<roman>.md` — Task files
