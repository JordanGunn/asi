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

The **doctor** skill diagnoses software failures by combining deterministic evidence gathering with agent judgment.

## What It Does

- Models software failures as medical cases
- Gathers evidence through parameterized search (agent provides terms, script returns matches)
- Tracks symptoms, hypotheses, and confidence levels
- Produces schema-based treatment plans when diagnosis is confident

## What Problems It Solves

- Prevents premature action on incomplete understanding
- Separates observation from interpretation
- Makes uncertainty explicit (confidence percentages)
- Creates reviewable artifacts for handoff

## What It Is Not

- Not a fix-it skill (produces plans, not changes)
- Not a sequential pipeline (idempotent, run until confident)
- Not purely deterministic (balances scripts with agent reasoning)

## Key Invariant

**Execution means investigation, not implementation.** The skill gathers evidence and produces treatment plans. It does not execute fixes.

## Artifact Location

All artifacts stored in `.doctor/`:
- `session.yaml` — Current diagnosis state
- `evidence/` — Evidence snapshots
- `treatment.md` — Generated treatment plan
