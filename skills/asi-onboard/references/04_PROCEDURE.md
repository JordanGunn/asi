---
description: Canonical execution path for asi-onboard.
index:
  - Execution Model
  - Steps
  - Outputs
  - Failure Handling
---

# Procedure

## Execution Model

```text
Wrapper (init)  → Emits references deterministically
CLI (schema)    → Emits onboarding plan schema
Agent (plan)    → Produces plan JSON from user intent
CLI (run)       → Validates plan and advances onboarding state
```

## Steps

1. Run `./scripts/skill.sh init` to load references.
2. Retrieve the schema: `./scripts/skill.sh schema`.
3. Compile the onboarding plan JSON from user intent.
4. Execute via `./scripts/skill.sh run --stdin`.

## Outputs

Artifacts live under `.asi/onboard/`:

- `NOTES.md`
- `SOURCES.md`
- `STATE.json`

## Failure Handling

- If dependencies are missing, run `./scripts/skill.sh validate`.
- If the user requests planning or execution, route to `asi-creator`.
