---
description: Canonical procedure for listing and reanchoring findings.
index:
  - Inputs
  - List
  - Validate
  - Reanchor
  - Outputs
---

# Procedure

## Inputs

- `.sniff/findings.jsonl`
- Repository working tree

## List

1. Run `scripts/skill.sh list`.
2. Use filters (`--smell`, `--group`, `--path`) as needed.

## Validate

1. Run `scripts/skill.sh validate-findings`.
2. By default, only active findings are validated.

## Reanchor

1. Run `scripts/skill.sh reanchor`.
2. Stale/missing findings are searched and updated deterministically.

## Outputs

- Printed list (human) or JSON output when requested
- `.sniff/findings.jsonl` (append updates for status/range changes)
- `.sniff/index.json` (regenerated)
