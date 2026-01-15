---
description: When to invoke or exit this skill.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- A change should be documented in `[Unreleased]`.
- User asks to add a changelog entry.

## Do not invoke when

- No changelog exists (run `changelog-init` first).
- User is asking to cut a release (use `changelog-release`).

## Exit immediately if

- Category is not one of the canonical categories and the user won’t choose one.
