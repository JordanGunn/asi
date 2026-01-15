---
description: Common failure cases and how to surface them.
index:
  - Missing inputs
  - Missing tooling
---

# Failures

## Missing inputs

- If no `--glob` and no `--pattern` are provided, fail fast.

## Missing tooling

- If `rg` is missing, report it and instruct installation.
- Do not attempt auto-installation.
