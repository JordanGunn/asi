---
name: asi-kickoff
license: MIT
description: >
  Execute the ASI Skill Design Kickoff procedure to produce a high-level
  KICKOFF.md planning artifact. This skill scaffolds thinking, not implementation.
metadata:
  author: Jordan Godau
  version: 0.2.0
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
    - scripts/approve.sh
    - scripts/approve.ps1
  assets:
    - assets/schemas/kickoff_v1.schema.json
    - assets/schemas/skill_type_v1.schema.json
    - assets/schemas/single_skill_scaffold_v1.schema.json
    - assets/schemas/grouped_skill_scaffold_v1.schema.json
    - assets/schemas/step_output_v1.schema.json
    - assets/templates/KICKOFF.template.md
    - assets/templates/QUESTIONS.template.md
    - assets/procedure/
  artifacts:
    - .asi/kickoff/KICKOFF.md
    - .asi/kickoff/QUESTIONS.md
    - .asi/kickoff/SKILL_TYPE.json
    - .asi/kickoff/SCAFFOLD.json
    - .asi/kickoff/STATE.json
    - .asi/kickoff/step_*_output.json
  keywords:
    - kickoff
    - planning
    - design
    - scaffold
    - asi
---

# INSTRUCTIONS

1. Run `scripts/init.sh --skill-name "<name>" --skill-purpose "<purpose>"` first.
2. Then refer to `metadata.references` for the procedure.
