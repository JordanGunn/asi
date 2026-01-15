---
description: Non-negotiable invariants for this skill.
index:
  - Execution Rules
  - Status Rules
  - Artifact Rules
  - Scope Rules
---

# Always

Non-negotiable invariants for the plan skillset.

## Execution Rules

- Always perform the actual work described in Work sections
- Always verify results exist on disk before marking complete
- Always write concrete Output (not descriptions of what could be done)
- Always provide clear Handoff for next task

## Status Rules

- Always update frontmatter status when starting/completing tasks
- Always use `./skill.sh status` to check current state
- Always execute tasks in order (a→b→c, i→ii→iii)

## Artifact Rules

- Always store plans in `.plan/<N>/`
- Always use the canonical structure (plan.md, letter/index.md, letter/roman.md)
- Always include frontmatter with status field

## Scope Rules

- Always get user approval before expanding scope
- Always complete current sub-plan before moving to next
