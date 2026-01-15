---
description: Canonical execution path for this skill.
index:
  - Step 1: Verify Source
  - Step 2: Run Split Script
  - Step 3: Generate Index
  - Step 4: Verify Output
  - Output Structure
---

# Procedure

Execution path for the md-split skill.

## Step 1: Verify Source

Confirm the source file exists and is markdown:

```bash
ls -la <source.md>
```

## Step 2: Run Split Script

```bash
./scripts/split.sh <source.md> [output_dir]
```

Or on Windows:

```powershell
./scripts/split.ps1 <source.md> [output_dir]
```

## Step 3: Generate Index

```bash
./scripts/index.sh [output_dir]
```

## Step 4: Verify Output

Check that chunks were created:

```bash
ls -la <output_dir>/*.md
```

## Output Structure

```text
output_dir/
├── 00_preamble.md     # Content before first H2
├── 01_section_one.md  # First H2 section
├── 02_section_two.md  # Second H2 section
└── .INDEX.md          # Generated index
```
