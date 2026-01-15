---
description: What sniff-locate does and does not do.
index:
  - What it does
  - What it is not
---

# Summary

`sniff-locate` lists smell findings from `.sniff/findings.jsonl`, validates stored anchors, and deterministically reanchors stale findings when code moves. It regenerates `.sniff/index.json`.

## What it does

- Lists findings with stable sort and filtering
- Validates stored `core_hash` against current `path+range`
- Reanchors stale/missing findings using a deterministic search
- Regenerates `.sniff/index.json`

## What it is not

- Not a smell detector (does not create new findings)
- Not allowed to delete findings from the ledger
- Not allowed to guess or wander; it follows deterministic search rules
