---
description: What sniff-preventers does and does not do.
index:
  - What it does
  - What it is not
---

# Summary

`sniff-preventers` scans tracked files for a minimal set of change preventers smells using deterministic, cheap heuristics. It appends findings to `.sniff/findings.jsonl` and regenerates `.sniff/index.json`.

## What it does

- Scans files deterministically via `git ls-files`
- Detects a minimal set of preventers smells
- Appends new findings to `.sniff/findings.jsonl`
- Regenerates `.sniff/index.json` and `.sniff/state.json`

## What it is not

- Not a refactoring or fix tool
- Not a deep semantic analyzer
- Not allowed to delete findings from the ledger
