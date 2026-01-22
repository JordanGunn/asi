# Router

---

## Preconditions

### Execute

1. `scripts/validate.sh --check kickoff`

### Check

- If user explicitly requests "start fresh", ignore existing KICKOFF.md.

---

## Routes

1. kickoff-exists
2. default

---

### kickoff-exists

Resume or review existing kickoff artifact.

**When:**

- `validate --check kickoff` exits 0
- `KICKOFF.md` exists in working directory

**Read:**

1. 01_SUMMARY.md
2. 07_FAILURES.md

**Ignore:**

1. 02_CONTRACTS.md
2. 03_TRIGGERS.md
3. 04_NEVER.md
4. 05_ALWAYS.md
5. 06_PROCEDURE.md

#### Goto

07_FAILURES.md#existing-kickoff

---

### default

Fresh kickoff — read all references in order.

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
