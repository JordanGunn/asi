---
description: Reference file for Instructions.
index:
  - Initialize
  - Policies
---

# Instructions

## Initialize

1. Read all reference files listed in `metadata.references` in order before taking action.

## Policies

### Always

1. Create tasks via `../.shared/scripts/skill.sh create`.
2. Use kebab-case task IDs.
3. Use `--select` when the user wants the task activated.

### Never

1. Never manually create `.tasks/<id>.md` when the CLI can do it.
