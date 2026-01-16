---
description: Canonical execution path for this skill.
index:
  - Step 0: Compile surface plan
  - Step 1: Compile search plan (JSON)
  - Step 2: Run search (explicit args)
  - Step 3: Interpret surface results
  - CLI
---

# Procedure

## Step 0: Compile surface plan

- Compile a `grape_surface_plan_v1` from the prompt (bounded globs + policy).
- Run `scripts/scan.sh`/`scripts/scan.ps1` with those arguments to produce the surface snapshot receipt.

## Step 1: Compile search plan (JSON)

- Treat `/grape <prompt>` as `grape_intent_v1`.
- Compile to `grape_compiled_plan_v1` (explicit `--root/--pattern/--glob/--exclude/...`).
- Run `scripts/plan.sh`/`scripts/plan.ps1 --stdin` to validate the compiled plan, emit the receipt, and gate the search.
- Use the templates/examples in `assets/templates/` and `assets/examples/` to keep shape consistent.
- Keep expansions and probe count bounded and visible.

## Step 2: Run search (explicit args)

- Run the CLI with explicit parameters using `scripts/grep.sh`/`scripts/grep.ps1`.
- Review the echoed parameter block before using results.

## Step 3: Interpret surface results

- Use file paths and distributions to select next hypotheses.
- Refine by changing one dimension at a time.

## CLI

From `skills/grape/`, run:

```bash
./scripts/grep.sh --root . --pattern "term" --mode fixed --case smart
```
