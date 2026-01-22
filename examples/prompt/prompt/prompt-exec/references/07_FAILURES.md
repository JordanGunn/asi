---
description: What to do when things go wrong.
index:
  - Failure Modes
  - Recovery
---

# Failures

## Failure Modes

1. **No artifact** — `.prompt/active.yaml` does not exist
2. **Status not ready** — artifact exists but is not `ready`
3. **Consent not explicit** — execution must not proceed
4. **Exec fails** — script execution fails or receipt cannot be written

## Recovery

- Abort on missing consent
- Preserve the active artifact on failure for retry
- Use `--dry-run` for a non-destructive preflight
