---
description: What this skill is and is not.
index:
  - What it does
  - What it is not
---

# Summary

`dtx-state` makes the agent’s **current admissible working set** explicit by reading `.dtx/CONTRACT.yml` (authoritative) and summarizing `.dtx/FORGET.yml` (revoked premises).

## What it does

- Shows effective `intent`
- Shows `working_set` sections (decisions/constraints/facts/assumptions/open_questions)
- Summarizes revoked premises (from `.dtx/FORGET.yml`)

## What it is not

- Not a database or indexing system
- Not a truth oracle (it only reports what is in `.dtx/`)
