---
description: Canonical execution path for this skill.
index:
  - "Step 1: Verify Preconditions"
  - "Step 2: Compile Deterministically"
  - "Step 3: Optional Single-Pass Polish"
  - "Step 4: Confirm Outputs"
---

# Procedure

## Step 1: Verify Preconditions

Verify `.prompt/active.yaml` exists. If it does not, stop and use `prompt-forge` first.

## Step 2: Compile Deterministically

Run the deterministic compiler:

```bash
./scripts/compile.sh
```

This generates `.prompt/PROMPT.md` from the artifact.

## Step 3: Optional Single-Pass Polish

If the user requests it, apply a single subjective editing pass to `.prompt/PROMPT.md`:

- Smooth awkward phrasing
- Remove redundancy
- Clarify ambiguous language

Write the polished version back to `.prompt/PROMPT.md`.

## Step 4: Confirm Outputs

Inform the user that PROMPT.md is ready.

The YAML artifact remains intact for reference or re-compilation.
