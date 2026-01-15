---
description: Non-negotiable invariants for sniff-locate.
index:
  - Policies
---

# Always

## Policies

- Always treat `.sniff/findings.jsonl` as append-only.
- Always use deterministic ordering and tie-breakers.
- Always regenerate `.sniff/index.json` from the ledger.
