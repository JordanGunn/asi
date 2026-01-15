---
description: Forbidden behaviors for this skill.
index:
  - No Data Loss
  - No Format Changes
  - No Silent Failures
  - No Scope Creep
---

# Never

Forbidden behaviors for the md skillset.

## No Data Loss

- Never delete source files
- Never overwrite without --force flag
- Never lose content during split/merge

## No Format Changes

- Never modify content within chunks
- Never change heading levels unexpectedly
- Never add or remove markdown formatting

## No Silent Failures

- Never ignore lint errors
- Never skip validation steps
- Never merge without verifying chunk integrity

## No Scope Creep

- Never process non-markdown files
- Never perform semantic editing
- Never restructure document hierarchy without consent
