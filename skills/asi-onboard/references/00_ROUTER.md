# Router

---

## Preconditions

### Execute

1. `scripts/validate.sh --check session`

### Check

- If user explicitly requests "start fresh", ignore existing onboarding artifacts.
- If user requests planning or execution, do not onboard — route them to `asi-plan` / `asi-exec`.

---

## Routes

1. session-active
2. default

---

### session-active

Resume or extend an existing onboarding session.

**When:**

- `validate --check session` exits 0
- `.asi/onboard/STATE.json` exists

**Read:**

1. 01_SUMMARY.md
2. 06_PROCEDURE.md
3. 07_FAILURES.md

**Ignore:**

1. 02_CONTRACTS.md
2. 03_TRIGGERS.md
3. 04_NEVER.md
4. 05_ALWAYS.md

---

### default

Fresh onboarding — read all references in order.

**When:**

- No other route matches

**Read:**

1. 01_SUMMARY.md
2. 02_CONTRACTS.md
3. 03_TRIGGERS.md
4. 04_NEVER.md
5. 05_ALWAYS.md
6. 06_PROCEDURE.md
7. 07_FAILURES.md

**Ignore:**

(none)
