# Contracts

## Invariants

- Preserve existing skill behavior unless explicitly approved.
- Keep `SKILL.md` concise; put details in `references/`.
- Use scripts for deterministic, repeatable steps.
- Avoid adding network calls without explicit user approval.
- All enhancements must be recorded in `.asi/enhance/ENHANCEMENT_REPORT.md`.
- Record which artifacts you reviewed (`STATE.json`, `SCAN.md`, `CHANGELOG_ENTRY.md`) and which router route you followed before touching files.
- Require explicit plan approval (or an `asi-exec` hand-off) before editing; log any sensitive operations that affect other skills or structural behavior as part of the enhancement report.

## Compatibility

- Do not break existing skill triggers or usage patterns.
- Do not rename skill directories or SKILL.md without explicit approval.

## Safety

- Avoid destructive scripts.
- Do not overwrite user files without a backup or explicit approval.
