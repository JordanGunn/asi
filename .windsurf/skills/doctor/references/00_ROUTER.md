---
description: Conditional dispatch for which reference files to load.
index:
  - Preconditions
  - Routes
---

# Router

---

## Preconditions

### Execute

1. scripts/router_checks.sh --check session
2. scripts/router_checks.sh --check treatment

### Fresh Start Override

If the user explicitly requests a fresh start, force the router into the `default` route by making the checks fail deterministically:

1. Set `DOCTOR_FRESH_START=1` for the router check invocation, **or**
2. Pass `--fresh-start` to `scripts/router_checks.sh`

### Check

- If user explicitly requests a fresh start, treat as `default` even if artifacts exist.

---

## Routes

1. treatment-complete
2. session-active
3. default

---

### treatment-complete

Resume after a treatment plan has already been generated.

**When:**

- `scripts/router_checks.sh --check treatment` exits 0

**Read:**

1. 01_SUMMARY.md

**Ignore:**

1. 02_TRIGGERS.md
2. 03_ALWAYS.md
3. 04_NEVER.md
4. 05_PROCEDURE.md
5. 06_FAILURES.md

---

### session-active

Resume mid-investigation when a session exists but treatment is not yet generated.

**When:**

- `scripts/router_checks.sh --check session` exits 0
- `scripts/router_checks.sh --check treatment` exits non-zero

**Read:**

1. 01_SUMMARY.md
2. 03_ALWAYS.md
3. 05_PROCEDURE.md

**Ignore:**

1. 02_TRIGGERS.md
2. 04_NEVER.md
3. 06_FAILURES.md

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
