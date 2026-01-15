---
name: dtx-forget
license: MIT
description: >
  Revoke a premise by appending to `.dtx/FORGET.yml`, and update `.dtx/CONTRACT.yml`
  where safe.
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
  keywords:
    - dtx
    - disk
    - context
    - forget
    - revoke
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
