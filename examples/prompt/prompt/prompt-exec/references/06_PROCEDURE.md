---
description: Canonical execution path for this skill.
index:
  - Preconditions
  - "Step 1: Verify Preconditions"
  - "Step 2: Quote Before Execute"
  - "Step 3: Execute and Emit Prompt"
  - "Step 4: Perform the Prompt"
  - "Step 5: Confirm Completion"
---

# Procedure

## Preconditions

All must be satisfied before execution:

1. **Artifact exists**: `.prompt/active.yaml` must exist
2. **Status is ready**: `status: ready` in artifact
3. **User consent**: explicit and unambiguous confirmation

## Step 1: Verify Preconditions

```bash
./scripts/exec.sh --dry-run
```

If preconditions are not met, stop and return the error output.

## Step 2: Quote Before Execute

Display the exact prompt text to the user before execution.

Ask: "Execute this prompt now?"

## Step 3: Execute and Emit Prompt

Run the deterministic execution script:

```bash
./scripts/exec.sh
```

On success, this script will:

1. Write an execution receipt
2. Delete the active artifact
3. Print the exact prompt text to execute

## Step 4: Perform the Prompt

Perform the printed prompt exactly as written (no reinterpretation).

## Step 5: Confirm Completion

After execution, the system returns to "no active prompt" state.
