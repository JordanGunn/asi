---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather inputs
  - Step 2: Append forget entry
  - Step 3: Update contract (when safe)
  - CLI
---

# Procedure

## Step 1: Gather inputs

- `claim` (required)
- `reason` (required)
- `scope` (optional; default `global`)
- `replacement` (optional)

## Step 2: Append forget entry

- Ensure `.dtx/` exists.
- Append a new entry to `.dtx/FORGET.yml`.

## Step 3: Update contract (when safe)

- If `.dtx/CONTRACT.yml` exists:
  - Remove exact matches from `facts`, `assumptions`, `open_questions`, and `out_of_scope`.
  - If the claim matches `decisions` or `constraints`, do not guess—report conflict.

## CLI

From `skills/dtx/dtx-forget/`, run:

```bash
./scripts/skill.sh forget "<claim>" --reason "<reason>" --scope global
```
