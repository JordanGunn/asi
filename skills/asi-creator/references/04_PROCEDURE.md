---
description: Canonical execution path for asi-creator.
index:
  - Execution Model
  - Steps
  - Output
---

# Procedure

## Execution Model

```text
CLI (next)     → Emit up to 3 questions
Agent          → Propose 1–3 options for each
CLI (suggest)  → Validate options + emit ask set
User           → Select 1–4 (4 = alternative)
CLI (apply)    → Persist decisions + advance phase
```

## Steps

1. Run `asi creator next` to get open questions.
2. Use `asi creator suggest --stdin` to validate agent options.
3. Present options to the user and capture answers.
4. Apply answers with `asi creator apply --stdin`.
5. Repeat until `status: ready`, then proceed to phase execution via `asi creator run`.

## Output

Artifacts live under `.asi/creator/`:

- `kickoff/KICKOFF.md`
- `plan/PLAN.md`
- `plan/TODO.md`
- `exec/RECEIPT.md`
