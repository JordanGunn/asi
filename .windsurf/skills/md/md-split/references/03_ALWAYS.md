---
description: Non-negotiable invariants for this skill.
index:
  - Split Rules
  - Output Rules
  - Script Rules
---

# Always

Non-negotiable invariants for the md-split skill.

## Split Rules

- Always split on H2 headings (`## `)
- Always number output files sequentially (01, 02, 03...)
- Always preserve content before first H2 as chunk 00
- Always use deterministic output names

## Output Rules

- Always create output in same directory as source
- Always generate an index file
- Always include original heading in each chunk

## Script Rules

- Always use the provided scripts for splitting
- Always verify source file exists before splitting
- Always report number of chunks created
