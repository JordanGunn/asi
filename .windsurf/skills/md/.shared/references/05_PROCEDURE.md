---
description: Canonical execution path for this skill.
index:
  - Commands
  - Split Flow
  - Merge Flow
  - Review Flow
  - Output Structure
---

# Procedure

CLI commands for the md skillset.

## Commands

```bash
./skill.sh help                    # Show help
./skill.sh validate                # Check runnable
./skill.sh split <file> [--out X]  # Split by H2
./skill.sh merge <dir> [--out X]   # Merge chunks
./skill.sh lint <file|dir>         # Check markdown
./skill.sh index <dir>             # Generate index
./skill.sh clean <dir>             # Remove generated files
```

## Split Flow

```bash
./skill.sh split large.md --out chunks/
./skill.sh lint chunks/
./skill.sh index chunks/
```

## Merge Flow

```bash
./skill.sh lint chunks/           # Pre-merge check
./skill.sh merge chunks/ --out merged.md
./skill.sh lint merged.md         # Post-merge check
```

## Review Flow

After deterministic operations, invoke md-review for agent quality assessment.

## Output Structure

```text
chunks/
├── 00_INTRO.md        # Content before first H2
├── 01_SECTION_ONE.md  # First H2 section
├── 02_SECTION_TWO.md  # Second H2 section
├── .INDEX.md          # Generated index
└── .SPLIT.json        # Manifest
```
