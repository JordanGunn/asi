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
    - references/01_SUMMARY.md
    - references/02_INTENT.md
    - references/03_POLICIES.md
    - references/04_PROCEDURE.md
  scripts:
    - scripts/skill.sh
    - scripts/skill.ps1
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

1. Run `./scripts/skill.sh init` first.
2. Then refer to `metadata.references` for the procedure.
