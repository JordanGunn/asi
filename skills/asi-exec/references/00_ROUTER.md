# Router

---

## Preconditions

### Execute

1. `scripts/validate.sh --check plan-approved`
2. `scripts/validate.sh --check plan-drift`

### Check

- PLAN.md must exist with `status: approved`
- PLAN.md must not have drifted (hash match)
- If user explicitly requests specific task, filter to that task

---

## Routes

1. plan-not-approved
2. drift-detected
3. all-done
4. default

---

### plan-not-approved

Halt — cannot execute without approved plan.

**When:**

- `validate --check plan-approved` exits non-zero
- PLAN.md does not exist OR `status` is not `approved`

**Read:**

1. 01_SUMMARY.md
2. 07_FAILURES.md

#### Goto

07_FAILURES.md#plan-not-approved

---

### drift-detected

Halt — upstream artifact has changed.

**When:**

- `validate --check plan-drift` exits non-zero
- PLAN.md hash doesn't match stored hash in TODO.md

**Read:**

1. 01_SUMMARY.md
2. 07_FAILURES.md

#### Goto

07_FAILURES.md#drift-detected

---

### all-done

All tasks complete — report summary.

**When:**

- PLAN.md is approved
- No drift detected
- All tasks in TODO.md have `status: done`

**Read:**

1. 01_SUMMARY.md
2. 07_FAILURES.md

#### Goto

07_FAILURES.md#all-done

---

### default

Execute next pending task.

**When:**

- PLAN.md is approved
- No drift detected
- At least one task has `status: pending` or `status: in_progress`

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
