---
description: Non-negotiable invariants for this skill.
index:
  - Artifact Rules
  - Selection Rules
  - Lifecycle Rules
  - CLI Rules
---

# Always

Non-negotiable invariants for the task skillset.

## Artifact Rules

- Always store tasks in `.task/`
- Always use content-addressed filenames (hash-based)
- Always include frontmatter with status field
- Always use the task template schema

## Selection Rules

- Always check for active task before selecting new one
- Always deselect or close current before switching
- Always use `./skill.sh list` to view tasks

## Lifecycle Rules

- Always set status: open on creation
- Always set status: closed on completion
- Always record completion time in frontmatter

## CLI Rules

- Always use `./skill.sh validate` before operations
- Always use `./skill.sh list` to check current state
