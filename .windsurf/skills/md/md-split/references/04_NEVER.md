---
description: Forbidden behaviors for this skill.
index:
  - No Data Loss
  - No Format Changes
  - No Scope Creep
---

# Never

Forbidden behaviors for the md-split skill.

## No Data Loss

- Never delete the source file
- Never overwrite existing chunks without warning
- Never lose content during split

## No Format Changes

- Never modify content within chunks
- Never change heading levels
- Never add or remove markdown formatting

## No Scope Creep

- Never split on headings other than H2
- Never merge files (split only)
- Never process non-markdown files
