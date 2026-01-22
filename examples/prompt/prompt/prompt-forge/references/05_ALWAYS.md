---
description: Non-negotiable invariants for this skill.
index:
  - Invariants
---

# Always

## Invariants

1. Always treat the on-disk artifact (`.prompt/active.yaml`) as the source of truth
2. Always keep all skill state changes scoped to `.prompt/`
3. Always maintain exactly one active artifact at `.prompt/active.yaml`
4. Always reflect proposed artifact updates back to the user before persisting
5. Always require explicit user confirmation before marking `status: ready`
