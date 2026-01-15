---
description: Canonical execution path for this skill.
index:
  - Step 1: Verify Artifact (Deterministic)
  - Step 2: Compile to Markdown (Deterministic)
  - Step 3: Review Output (Subjective)
  - Step 4: Polish (Subjective, Single Pass)
  - Step 5: Confirm
---

# Procedure

## Step 1: Verify Artifact (Deterministic)

Check that the YAML artifact exists and is valid:

```bash
../../.shared/scripts/skill.sh status
```

If no artifact exists, direct user to `prompt-forge`.

## Step 2: Compile to Markdown (Deterministic)

Run the deterministic compile command:

```bash
../../.shared/scripts/skill.sh compile
```

This generates `.prompt/PROMPT.md` from the artifact.

## Step 3: Review Output (Subjective)

Read the generated PROMPT.md and assess:

- **Fluidity**: Does it read naturally?
- **Conciseness**: Is there unnecessary verbosity?
- **Gaps**: Is any intent missing or unclear?
- **Misinterpretations**: Does the output match the intent?

## Step 4: Polish (Subjective, Single Pass)

Apply a single editing pass to the PROMPT.md:

- Smooth awkward phrasing
- Remove redundancy
- Clarify ambiguous language
- Ensure constraints are explicit

Write the polished version back to `.prompt/PROMPT.md`.

## Step 5: Confirm

Inform the user that PROMPT.md is ready.

The YAML artifact remains intact for reference or re-compilation.
