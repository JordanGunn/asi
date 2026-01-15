---
description: What this skill is and is not.
index:
  - What It Does
  - What Problems It Solves
  - What It Is Not
  - Key Invariant
  - Artifact Location
---

# Summary

The **prompt** skillset shapes, refines, and executes prompts through a structured artifact workflow.

## What It Does

- Forges prompts through iterative refinement (prompt-forge)
- Compiles YAML artifacts to markdown (prompt-compile)
- Executes finalized prompts (prompt-exec)

## What Problems It Solves

- Prevents premature execution of unrefined prompts
- Creates reviewable prompt artifacts
- Separates intent formation from execution
- Tracks prompt state with frontmatter status

## What It Is Not

- Not for trivial one-off requests
- Not for prompts that don't need refinement
- Not purely subjective (CLI provides deterministic operations)

## Key Invariant

**Forge before execute.** Prompts must reach `status: ready` through refinement before execution. Prompt-exec will not run on unready artifacts.

## Artifact Location

All artifacts stored in `.prompt/`:

- `active.yaml` — Current prompt artifact
- `PROMPT.md` — Compiled markdown (after compile)
- `receipts/` — Execution receipts
