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
2. **Compile fails** — Check CLI output for errors
3. **Status not ready** — Warn user; allow compile with `--force`
4. **Polish introduces errors** — Re-run compile; apply smaller edit

## Recovery

- Always prefer re-running deterministic compile over manual fixes
- Preserve original artifact for re-compilation

## Shared Context

Refer to `../../.shared/references/06_FAILURES.md` for skillset-level failure handling.
