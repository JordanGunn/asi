# Failure Modes

## no-active-plan

**Symptom:** Script reports "No active plan"

**Cause:** `.plan/active.yaml` does not exist

**Recovery:** Run `scripts/init.sh --name "<name>"` to create a plan

---

## step-not-found

**Symptom:** Script reports "Step X not found"

**Cause:** Invalid step ID

**Recovery:** Run `scripts/status.sh` to see valid step IDs

---

## incomplete-steps

**Symptom:** Archive fails with "incomplete steps"

**Cause:** Attempting to archive with pending/in_progress steps

**Recovery:** Complete steps or use `--force` with user consent

---

## state-missing

**Symptom:** Script reports "STATE.json missing"

**Cause:** STATE.json was deleted or corrupted

**Recovery:** Recreate STATE.json or reinitialize with `--force`
