---
description: Canonical execution path for this skill.
index:
  - Step 1: Run Verify
  - Step 2: Review Output
  - Step 3: Report
---

# Procedure

## Step 1: Run Verify

```bash
../.shared/scripts/skill.sh verify
```

Or specify path:

```bash
../.shared/scripts/skill.sh verify path/to/CHANGELOG.md
```

## Step 2: Review Output

If issues found:

- Review each reported issue
- Fix manually or use CLI commands
- Re-run verify to confirm

## Step 3: Report

Present findings to user with specific recommendations.
