---
description: What to do when things go wrong.
index:
  - Failure Modes
  - Recovery
  - Shared Context
---

# Failures

## Failure Modes

1. **No artifact after init** — CLI `init` failed; check permissions
2. **User never confirms** — Remain in drafting state; do not force ready
3. **Conflicting constraints** — Surface contradictions; ask user to resolve
4. **Ambiguous intent** — Add to open_questions; continue refinement

## Recovery

- Always prefer asking over guessing
- Never auto-resolve ambiguity
- Document unresolved questions in artifact

## Shared Context

Refer to `../../.shared/references/06_FAILURES.md` for skillset-level failure handling.
