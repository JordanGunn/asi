---
description: What to do when things go wrong.
index:
  - Failure Modes
  - Recovery
---

# Failures

## Failure Modes

1. **Artifact cannot be written** — permissions or invalid working directory
2. **User never confirms readiness** — the artifact remains `drafting`
3. **Conflicting constraints** — contradictions exist in proposed updates
4. **Ambiguous intent** — open questions remain and block readiness

## Recovery

- Prefer explicit confirmation over inference
- Keep unresolved questions in `intent.open_questions`
