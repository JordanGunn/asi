# Router

## Preconditions

1. Identify the target skill path.
2. Run `scripts/init.sh --skill-path "<path>"`.
3. Run `python3 scripts/scan_skill.py --skill-path "<path>" --out-dir ".asi/enhance"`.

## Routes

1. already-asi
2. convert-to-asi
3. enhance-only

### already-asi

Use when the target already follows the ASI-style structure in this repo:

- Has `SKILL.md`
- Has `assets/`, `scripts/`, `references/`
- References numbered procedure files or is already aligned to ASI workflow

**Read:**

1. 01_SUMMARY.md
2. 04_NEVER.md
3. 05_ALWAYS.md
4. 06_PROCEDURE.md
5. 08_CHECKLISTS.md

### convert-to-asi

Use when the target is a minimal or legacy skill that needs ASI-style structure added.

**Read:**

1. 01_SUMMARY.md
2. 02_CONTRACTS.md
3. 04_NEVER.md
4. 05_ALWAYS.md
5. 06_PROCEDURE.md
6. 08_CHECKLISTS.md

### enhance-only

Use when the user requests hardening or capability improvements without structural changes.

**Read:**

1. 01_SUMMARY.md
2. 05_ALWAYS.md
3. 06_PROCEDURE.md
4. 08_CHECKLISTS.md
