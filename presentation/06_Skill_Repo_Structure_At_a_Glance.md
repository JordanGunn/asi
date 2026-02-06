# Skill Structure (At a Glance)

<!-- fit -->

## A skill is a directory with a declared surface

- `SKILL.md`: manifest/entrypoint (declares the surface)
- `references/`: instruction surface (small, ordered docs)
- `assets/`: legacy-only (V2 prefers CLI-emitted schemas/templates)
- `scripts/`: deterministic entrypoints (discovery, validation, transforms)

## Why this structure matters

- Keeps the “source of truth” on disk
- Makes scope + procedure readable and reviewable
- Makes validation mechanical (not “trust me”)

<!--
Speaker notes:
- Example skill to show next: `skills/asi-creator/`
-->
