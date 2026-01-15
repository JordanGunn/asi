---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather inputs
  - Step 2: Run expand
  - Step 3: Summarize
  - CLI
---

# Procedure

## Step 1: Gather inputs

- `root` (optional; default `.`)
- `globs[]` (repeatable `--glob`)
- `rg_patterns[]` (repeatable `--pattern`)

## Step 2: Run expand

- Compute `EXP-ID` from normalized inputs.
- Create `.dtx/EXPANDS/<EXP-ID>/`.
- Write:
  - `files.txt`
  - `matches.txt`
  - `meta.yml`

## Step 3: Summarize

- Print file count and match count.

## CLI

From `skills/dtx/dtx-gather/`, run:

```bash
./scripts/skill.sh expand --root . --glob "src/**/*.py" --pattern "TODO"
```
