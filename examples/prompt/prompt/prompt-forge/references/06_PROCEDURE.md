---
description: Canonical execution path for this skill.
index:
  - "Step 1: Check State"
  - "Step 2: Propose Artifact Update"
  - "Step 3: Persist Artifact Update"
  - "Step 4: Mark Ready"
  - "Step 5: Handoff"
---

# Procedure

## Step 1: Check State

Establish the current state of `.prompt/active.yaml` and surface validation errors:

```bash
./scripts/forge.sh
```

If the artifact does not exist, `forge.sh` creates an empty one.

## Step 2: Propose Artifact Update

From the conversation, propose an update to the artifact fields:

- `intent.objective`
- `intent.constraints`
- `intent.assumptions`
- `intent.open_questions`
- `prompt`

Present the proposed update to the user for confirmation.

## Step 3: Persist Artifact Update

Apply the confirmed changes by editing `.prompt/active.yaml`.

After writing, re-run `forge.sh` to surface status and any validation errors:

```bash
./scripts/forge.sh
```

## Step 4: Mark Ready

Only when the user explicitly confirms readiness, mark the artifact ready:

```bash
./scripts/forge.sh --mark-ready
```

If open questions remain, do not mark the artifact ready.

## Step 5: Handoff

Stop after the artifact is stable and ready. Subsequent actions happen in other skills.
