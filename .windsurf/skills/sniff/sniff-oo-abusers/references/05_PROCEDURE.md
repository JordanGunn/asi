---
description: Canonical procedure for running sniff-oo-abusers.
index:
  - Inputs
  - Steps
  - Outputs
---

# Procedure

## Inputs

- Repository working tree

## Steps

1. Run `scripts/skill.sh validate`.
2. Run `scripts/skill.sh scan`.

## Outputs

- `.sniff/findings.jsonl` (append-only)
- `.sniff/index.json` (regenerated)
- `.sniff/state.json` (regenerated)
