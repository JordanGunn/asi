---
description: Non-negotiable invariants for this skill.
index:
  - Invariants
---

# Always

## Invariants

1. Always treat `.prompt/active.yaml` as read-only input
2. Always keep all skill state changes scoped to `.prompt/`
3. Always generate `.prompt/PROMPT.md` via the deterministic script before any subjective edits
4. Always preserve `.prompt/active.yaml`
