---
name: asi-onboard
license: MIT
description: >
  Establish disk-backed repository context by reading ASI documentation entrypoints
  and recording a scoped context digest. Produces onboarding artifacts only (no kickoff,
  no plan, no execution).
metadata:
  author: Jordan Godau
  version: 0.1.0
  references:
    - references/00_ROUTER.md
    - references/01_SUMMARY.md
    - references/02_CONTRACTS.md
    - references/03_TRIGGERS.md
    - references/04_NEVER.md
    - references/05_ALWAYS.md
    - references/06_PROCEDURE.md
    - references/07_FAILURES.md
  scripts:
    - scripts/bootstrap.sh
    - scripts/bootstrap.ps1
    - scripts/init.sh
    - scripts/init.ps1
    - scripts/inject.sh
    - scripts/inject.ps1
    - scripts/checkpoint.sh
    - scripts/checkpoint.ps1
    - scripts/validate.sh
    - scripts/validate.ps1
  assets:
    - assets/schemas/step_output_v1.schema.json
    - assets/templates/NOTES.template.md
    - assets/templates/SOURCES.template.md
  artifacts:
    - .asi/onboard/NOTES.md
    - .asi/onboard/SOURCES.md
    - .asi/onboard/STATE.json
    - .asi/onboard/step_*_output.json
  keywords:
    - onboard
    - context
    - docs
    - asi
---

# INSTRUCTIONS

1. Run `scripts/init.sh` first.
2. Then refer to `metadata.references` for the procedure.
