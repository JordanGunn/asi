# Step 0 — Scaffold Repository Structure

The first action is to scaffold the **canonical directory structure**.

This structure is authoritative and must not drift.

## Single Skill Repository

```text
<skill-name>/
  README.md            # User-facing overview
  bootstrap.sh         # Dependency bootstrap (explicit consent required)
  bootstrap.ps1
  <skill-name>/        # Canonical skill root
    SKILL.md           # Must conform to ASI SKILL.md specification
    assets/
    scripts/
    references/        # Canonical reference files only
```

## Grouped Skill Repository

```text
<skill-prefix>/
  README.md
  bootstrap.sh
  bootstrap.ps1
  <skill-name-1>/
    SKILL.md
    assets/
    scripts/
    references/
  <skill-name-2>/
    SKILL.md
    assets/
    scripts/
    references/
  ...
```

## Reference Files

* Reference filenames and ordering **must** follow:

```text
../asi/docs/design/specs/references/
```

* These are the **only** reference files that may exist
* Empty files are acceptable; additional files are not

This step establishes structural determinism before reasoning begins.
