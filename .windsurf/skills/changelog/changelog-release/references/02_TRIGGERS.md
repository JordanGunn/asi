---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- User requests a release cut from `[Unreleased]`.
- Preparing to tag a release and changelog needs a version section.

## Do not invoke when

- `[Unreleased]` is missing.
- The changelog is failing verification and the user expects it to be fixed first.

## Exit immediately if

- Version is not explicitly provided by the user.
