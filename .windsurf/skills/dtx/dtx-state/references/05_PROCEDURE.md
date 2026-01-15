---
description: Canonical execution path for this skill.
index:
  - Step 1: Validate inputs
  - Step 2: Present effective state
  - Step 3: If missing contract
  - CLI
---

# Procedure

## Step 1: Validate inputs

- If `.dtx/CONTRACT.yml` exists, read it.
- If `.dtx/FORGET.yml` exists, read it.

## Step 2: Present effective state

- Print `intent`.
- Print each `working_set` list under its heading.
- Print a short revoked-premises summary (count + most recent items).

## Step 3: If missing contract

- Print: `no contract found: .dtx/CONTRACT.yml`.
- Print a blank contract template from `assets/CONTRACT_TEMPLATE.yml`.

## CLI

From `skills/dtx/dtx-state/`, run:

```bash
./scripts/skill.sh show
```
