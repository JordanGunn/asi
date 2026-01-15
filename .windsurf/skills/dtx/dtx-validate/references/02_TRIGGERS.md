---
description: Signals for when to use or not use this skill.
index:
  - Invoke when
  - Do not invoke when
---

# Triggers

## Invoke when

- Before relying on `.dtx/` contract contents
- After repository changes that might stale the contract
- When a user reports drift, inconsistency, or corruption

## Do not invoke when

- The user explicitly asked you to update the contract (validate first, then update via another skill)
