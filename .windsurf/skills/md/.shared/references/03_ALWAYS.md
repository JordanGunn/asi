---
description: Non-negotiable invariants for this skill.
index:
  - Determinism Rules
  - Quality Rules
  - Artifact Rules
  - CLI Rules
---

# Always

Non-negotiable invariants for the md skillset.

## Determinism Rules

- Always use CLI scripts for split/merge/lint operations
- Always run lint before merge to catch issues early
- Always generate manifest files for traceability
- Always preserve original heading hierarchy

## Quality Rules

- Always run lint after split to verify chunks
- Always run lint after merge to verify result
- Always report lint findings to user
- Always use md-review for subjective quality checks

## Artifact Rules

- Always number output files sequentially
- Always generate index files
- Always use deterministic naming patterns
- Always preserve source files (never delete)

## CLI Rules

- Always use `./skill.sh validate` before operations
- Always use `./skill.sh lint` to check markdown quality
