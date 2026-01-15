---
description: What to do when things go wrong.
index:
  - Failure Modes
  - Recovery
  - Shared Context
---

# Failures

## Failure Modes

1. **No artifact** — Direct user to `prompt-forge`
2. **Status not ready** — Direct user to `prompt-forge` to complete
3. **User declines** — Abort; artifact remains for later
4. **Exec fails** — Check CLI output; artifact preserved

## Recovery

- Always abort on missing consent
- Preserve artifact on failure for retry
- Use `--dry-run` to preview before real execution

## Shared Context

Refer to `../../.shared/references/06_FAILURES.md` for skillset-level failure handling.
