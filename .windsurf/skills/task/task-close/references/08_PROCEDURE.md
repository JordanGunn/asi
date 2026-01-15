---
description: Reference file for Procedure.
index:
  - Close
  - Verify
---

# Procedure

This file is kept for continuity. Prefer `05_PROCEDURE.md`.

## Close

```bash
../.shared/scripts/skill.sh close <id> --reason completed
```

or:

```bash
../.shared/scripts/skill.sh close <id> --reason abandoned
```

## Verify

```bash
../.shared/scripts/skill.sh list --state closed
```
