---
description: Non-negotiable invariants for this skill.
index:
  - Invariants
---

# Always

## Invariants

1. Always require explicit user consent before execution
2. Always require `.prompt/active.yaml` exists and has `status: ready`
3. Always quote the exact prompt text before executing it
4. Always write an execution receipt and delete the active artifact on success
