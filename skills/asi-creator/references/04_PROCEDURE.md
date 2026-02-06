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
CLI (apply)    → Persist decisions + advance session
```

## Steps

1. Run `asi creator next` to get open questions.
2. Use `asi creator suggest --stdin` to validate agent options.
3. Present options to the user and capture answers.
4. Apply answers with `asi creator apply --stdin`.
5. Repeat until `status: ready` (session has no open decisions).

`asi creator next` also emits:

- `schemas.suggest`: `asi creator suggest --schema`
- `schemas.apply`: `asi creator apply --schema`

### Schema Discoverability

Use schema emission before first invocation:

- `asi creator --schema` (run plan input)
- `asi creator suggest --schema` (suggest input)
- `asi creator apply --schema` (apply input)

### `suggest --stdin` input shape

```json
{
  "iteration_id": "<id-from-next>",
  "suggestions": [
    {
      "question_id": "creator.skill_name",
      "options": [
        {"label": "Option A", "value": "skill-a", "description": "Short rationale", "impact": "Low risk"},
        {"label": "Option B", "value": "skill-b", "description": "Alternative", "impact": "Medium risk"},
        {"label": "Option C", "value": "skill-c", "description": "Aggressive", "impact": "Higher risk"}
      ],
      "recommended": 1,
      "rationale": {"reasoning": "Why option 1 is preferred"}
    }
  ]
}
```

### `apply --stdin` input shape

```json
{
  "ask_set_id": "<id-from-suggest>",
  "answers": [
    {"question_id": "creator.skill_name", "selection": 1, "user_confirmation": true}
  ],
  "notes": "Optional operator notes"
}
```

Alternative confirmation shape:

```json
{
  "ask_set_id": "<id-from-suggest>",
  "confirmed": true,
  "answers": [
    {"question_id": "creator.skill_name", "selection": 1}
  ]
}
```

If validation fails, use the emitted `schema_cmd` hint in the error payload and rerun the matching `--schema` command.

## Output

Artifacts live under `.asi/creator/`:

- `state.json` (active session state)
- `ask_sets/<ask_set_id>.json` (validated option set snapshots)
- `decisions.log.jsonl` (append-only audit events)
- `receipts/<timestamp>.json` (apply outcomes)

Legacy compatibility (deprecated):

- `kickoff/`, `plan/`, `exec/` may still exist for one release bridge mode.
- If detected, creator emits a warning with deprecation guidance.
