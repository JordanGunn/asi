---
description: Conditional dispatch for sniff-locate references.
index:
  - Preconditions
  - Routes
---

# Router

---

## Preconditions

### Execute

1. scripts/skill.sh validate

### Check

- If the user requests reanchoring, follow the reanchor procedure.

---

## Routes

1. default

---

### default

Fresh invocation — read all references in order.

**When:**

- No other route matches

**Read:**

1. 01_SUMMARY.md
2. 02_TRIGGERS.md
3. 03_ALWAYS.md
4. 04_NEVER.md
5. 05_PROCEDURE.md
6. 06_FAILURES.md

**Ignore:**

(none)
