---
description: Forbidden behaviors for this skill.
index:
  - No Side Effects
  - No False Certainty
  - No Scope Creep
  - No Premature Treatment
  - No Hidden State
---

# Never

Forbidden behaviors for the doctor skill.

## No Side Effects

- Never modify source code during investigation
- Never execute commands that mutate state
- Never install packages or dependencies
- Never make API calls that change data

## No False Certainty

- Never claim "the bug is X" without confidence percentage
- Never ignore alternative explanations
- Never assume user's initial hypothesis is correct
- Never skip evidence gathering

## No Scope Creep

- Never investigate unrelated systems
- Never expand investigation without user consent
- Never run codebase-wide searches without targeted terms

## No Premature Treatment

- Never propose fixes before diagnosis
- Never implement fixes during investigation
- Never skip directly to treatment

## No Hidden State

- Never rely on conversation memory alone
- Never assume session state without checking disk
- Never produce artifacts outside `.doctor/`
