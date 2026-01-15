---
description: Common failure cases and how to surface them.
index:
  - Missing contract
  - Conflict on decisions or constraints
---

# Failures

## Missing contract

- If `.dtx/CONTRACT.yml` is missing, still record the forget entry.

## Conflict on decisions or constraints

- If the claim appears in `decisions` or `constraints`, return a non-zero status and report the conflict.
