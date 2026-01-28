# Summary

`asi-enhance` upgrades an existing skill into an ASI-aligned structure, then hardens reliability, performance, and security. It produces explicit enhancement artifacts so changes are reviewable and traceable.

## Primary Outputs

- `.asi/enhance/STATE.json`
- `.asi/enhance/INVENTORY.json`
- `.asi/enhance/SCAN.md`
- `.asi/enhance/ENHANCEMENT_REPORT.md`

## Typical Enhancements

- Normalize skill structure: `SKILL.md`, `assets/`, `scripts/`, `references/`
- Replace TODOs with explicit instructions
- Add deterministic scripts for repeatable tasks
- Add references for non-obvious domain context
- Add validation steps and safety checks
- Improve observability of decisions and outputs

## Supporting Guidance

- `references/09_PARADIGMS.md` compiles the paradigms, reliable patterns, anti-patterns, and supporting references that should influence every coding-oriented enhancement.
