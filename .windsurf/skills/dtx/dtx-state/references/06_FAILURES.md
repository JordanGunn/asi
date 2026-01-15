---
description: Common failure cases and how to surface them.
index:
  - Missing contract
  - Unparseable YAML
---

# Failures

## Missing contract

- Report that `.dtx/CONTRACT.yml` is missing.
- Print the blank template so the user can initialize intentionally.

## Unparseable YAML

- Report the parsing error.
- Do not guess or auto-repair.
