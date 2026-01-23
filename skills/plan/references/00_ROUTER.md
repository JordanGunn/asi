# Router

## Preconditions

### Execute

1. `scripts/validate.sh --check prereqs`

### Check

- Determine user intent (create, add-step, update-status, status, archive)

---

## Routes

1. no-plan
2. plan-exists
3. default

---

### no-plan

No active plan exists.

**When:**

- `.plan/active.yaml` does not exist

**Read:**

1. 01_SUMMARY.md
2. 06_PROCEDURE.md (init section only)

---

### plan-exists

Active plan exists.

**When:**

- `.plan/active.yaml` exists

**Read:**

1. 01_SUMMARY.md
2. 02_CONTRACTS.md
3. 06_PROCEDURE.md

---

### default

**When:**

- No other route matches

**Read:**

1. All references in order
