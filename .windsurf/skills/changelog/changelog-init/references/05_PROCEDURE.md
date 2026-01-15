---
description: Canonical execution path for this skill.
index:
  - Step 1: Check Existing
  - Step 2: Initialize
  - Step 3: Customize
  - Step 4: Commit
---

# Procedure

## Step 1: Check Existing

```bash
../.shared/scripts/skill.sh locate
```

If found, confirm user wants to overwrite.

## Step 2: Initialize

```bash
../.shared/scripts/skill.sh init [--force]
```

## Step 3: Customize

Guide user to update remote URL in link references if not auto-detected.

## Step 4: Commit

Suggest committing the new changelog.
