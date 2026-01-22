# Router

---

## Preconditions

### Execute

1. `scripts/validate.sh --check kickoff-approved`

### Check

- KICKOFF.md must exist and have `status: approved`
- If user explicitly requests "start fresh", ignore existing PLAN.md/TODO.md

---

## Routes

1. kickoff-not-approved
2. plan-exists
3. default

---

### kickoff-not-approved

Halt — cannot plan without approved kickoff.

**When:**

- `validate --check kickoff-approved` exits non-zero
- KICKOFF.md does not exist OR `status` is not `approved`

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

07_FAILURES.md#kickoff-not-approved

---

### plan-exists

Resume or review existing plan artifacts.

**When:**

- KICKOFF.md exists with `status: approved`
- PLAN.md exists in working directory

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

07_FAILURES.md#existing-plan

---

### default

Fresh plan — read all references in order.

**When:**

- KICKOFF.md exists with `status: approved`
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
