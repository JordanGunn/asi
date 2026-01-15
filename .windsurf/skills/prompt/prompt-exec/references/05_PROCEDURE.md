---
description: Canonical execution path for this skill.
index:
  - Preconditions
  - Step 1: Verify Preconditions (Deterministic)
  - Step 2: Quote Before Execute (Subjective)
  - Step 3: Execute (Deterministic)
  - Step 4: Perform the Prompt (Subjective)
  - Step 5: Confirm Completion
---

# Procedure

## Preconditions

All must be satisfied before execution:

1. **Artifact exists**: `.prompt/active.yaml` must exist
2. **Status is ready**: `status: ready` in artifact
3. **User consent**: Explicit trigger ("execute", "run", "go", "proceed")

## Step 1: Verify Preconditions (Deterministic)

```bash
../../.shared/scripts/skill.sh status
```

If status is not `ready`, abort and direct user to `prompt-forge`.

## Step 2: Quote Before Execute (Subjective)

Display the exact prompt text to the user before execution.

Ask: "Execute this prompt now?"

## Step 3: Execute (Deterministic)

Run the CLI exec command:

```bash
../../.shared/scripts/skill.sh exec
```

This will:

1. Write an execution receipt
2. Delete the active artifact
3. Output the prompt to execute

## Step 4: Perform the Prompt (Subjective)

Execute the prompt exactly as written. No reinterpretation.

## Step 5: Confirm Completion

After execution, the system returns to "no active prompt" state.
