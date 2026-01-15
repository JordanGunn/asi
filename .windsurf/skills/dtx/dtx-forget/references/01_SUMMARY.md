---
description: What this skill is and is not.
index:
  - What it does
  - What it is not
---

# Summary

`dtx-forget` revokes a premise by appending an entry to `.dtx/FORGET.yml`. If `.dtx/CONTRACT.yml` exists, it removes the exact claim from non-authoritative sections where safe.

## What it does

- Appends a new forget entry with stable `FGT-` identity
- Removes the exact claim from `facts`, `assumptions`, `open_questions`, and `out_of_scope`
- Detects conflicts if the claim appears in `decisions` or `constraints`

## What it is not

- Not an automatic refactoring tool
- Not allowed to guess edits to decisions or constraints
