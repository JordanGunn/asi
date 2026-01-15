---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather intent
  - Step 2: Choose parameters
  - Step 3: Run search
  - Step 4: Interpret surface results
  - CLI
---

# Procedure

## Step 1: Gather intent

- Identify the user’s target concept and the minimum evidence needed.

## Step 2: Choose parameters

- Choose root(s).
- Choose patterns (literal first).
- Choose include/exclude globs.
- Choose match mode and case behavior.

## Step 3: Run search

- Run the CLI with explicit parameters.
- Review the echoed parameter block before using results.

## Step 4: Interpret surface results

- Use file paths and distributions to select next hypotheses.
- Refine by changing one dimension at a time.

## CLI

From `skills/grape/`, run:

```bash
./scripts/skill.sh grep --root . --pattern "term" --mode fixed --case smart
```
