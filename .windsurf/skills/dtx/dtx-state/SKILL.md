---
name: dtx-state
license: MIT
description: >
  Present the current admissible working set from `.dtx/CONTRACT.yml`, alongside revoked premises from `.dtx/FORGET.yml`.
metadata:
  author: Jordan Godau
  version: 0.1.0
  references:
    - 00_ROUTER.md
    - 01_SUMMARY.md
    - 02_TRIGGERS.md
    - 03_ALWAYS.md
    - 04_NEVER.md
    - 05_PROCEDURE.md
    - 06_FAILURES.md
  scripts:
    - scripts/skill.sh
    - scripts/skill.ps1
  assets:
    - assets/CONTRACT_TEMPLATE.yml
    - assets/FORGET_TEMPLATE.yml
    - assets/EXPAND_META_TEMPLATE.yml
  keywords:
    - dtx
    - disk
    - context
    - state
    - contract
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
