---
description: Forbidden behaviors for this skill.
index:
  - No Premature Execution
  - No Artifact Destruction
  - No Scope Confusion
  - No Hidden State
---

# Never

Forbidden behaviors for the prompt skillset.

## No Premature Execution

- Never execute a prompt with status: draft
- Never skip the forge phase
- Never execute without explicit user consent

## No Artifact Destruction

- Never delete the YAML artifact after execution
- Never overwrite without user consent
- Never lose prompt history

## No Scope Confusion

- Never execute during forge phase
- Never forge during exec phase
- Never mix intent formation with execution

## No Hidden State

- Never rely on conversation memory alone
- Never assume artifact state without checking disk
- Never produce artifacts outside `.prompt/`
