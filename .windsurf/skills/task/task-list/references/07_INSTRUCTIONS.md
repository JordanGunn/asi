---
description: Reference file for Instructions.
index:
  - Initialize
  - Policies
---

# Instructions

This file is kept for continuity. Prefer the canonical reference set (00–06).

## Initialize

1. Read all reference files listed in `metadata.references` in order before taking action.

## Policies

### Always

1. List tasks via the deterministic CLI (`../.shared/scripts/skill.sh list`).
2. Surface skepticism flags (stale, hash mismatch).

### Never

1. Never infer task state without reading task files.
