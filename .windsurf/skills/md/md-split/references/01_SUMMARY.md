---
description: What this skill is and is not.
index:
  - What It Does
  - What Problems It Solves
  - What It Is Not
  - Key Invariant
  - Scripts
---

# Summary

The **md-split** skill splits markdown files by H2 headings into numbered documents.

## What It Does

- Splits a single markdown file into multiple files by H2 sections
- Numbers output files sequentially (01, 02, 03...)
- Generates an index file listing all chunks
- Preserves heading hierarchy within chunks

## What Problems It Solves

- Large markdown files that exceed context limits
- Documents needing section-level addressing
- Content that benefits from chunked processing

## What It Is Not

- Not for restructuring document hierarchy
- Not for merging files (one-way split only)
- Not for non-markdown formats

## Key Invariant

**Deterministic splitting.** Same input always produces same output. Split points are H2 headings only.

## Scripts

- `split.sh` / `split.ps1` — Perform the split
- `index.sh` / `index.ps1` — Generate index file
