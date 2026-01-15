---
description: Canonical execution path for this skill.
index:
  - Step 1: Check State (Deterministic)
  - Step 2: Gather Intent (Subjective)
  - Step 3: Reflect Understanding (Subjective)
  - Step 4: Update Artifact
  - Step 5: Mark Ready (Deterministic)
  - Step 6: Stop (Handoff)
---

# Procedure

## Step 1: Check State (Deterministic)

Run CLI to check current artifact state:

```bash
../../.shared/scripts/skill.sh status
```

If no artifact exists, initialize one:

```bash
../../.shared/scripts/skill.sh init
```

## Step 2: Gather Intent (Subjective)

Parse user input for intent signals. Identify:

- Core objective (what they want to accomplish)
- Constraints (must/must-not requirements)
- Assumptions (implicit context)
- Ambiguities (unclear or contradictory elements)

## Step 3: Reflect Understanding (Subjective)

Present back to the user:

- **Intent summary**: One-to-three lines of what you understand
- **Assumptions**: What you're assuming to be true
- **Open questions**: What remains unclear
- **Constraints**: Hard requirements and prohibitions

Ask: "Is this accurate? What should I adjust?"

## Step 4: Update Artifact

After user feedback:

1. Update the canonical artifact fields in `.prompt/active.yaml`.
2. Return to Step 3 until user confirms readiness.

## Step 5: Mark Ready (Deterministic)

Only when user explicitly confirms:

```bash
../../.shared/scripts/skill.sh ready
```

If open questions remain, use `--force` only with user consent.

## Step 6: Stop (Handoff)

1. Do not execute anything.
2. Do not call or emulate `prompt-exec`.
3. Inform user: "Prompt is ready. Invoke `prompt-compile` to generate PROMPT.md."
