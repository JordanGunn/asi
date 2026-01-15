---
description: Non-negotiable invariants for sniff-oo-abusers.
index:
  - Policies
---

# Always

## Policies

- Always discover files via `git ls-files`.
- Always keep output deterministic (stable ordering, stable IDs).
- Always append-only to `.sniff/findings.jsonl`.
