# Procedure

## Create Plan

```bash
scripts/init.sh --name "<plan-name>"
```

Creates `.plan/active.yaml` and `.plan/active/STATE.json`.

---

## Add Step

```bash
scripts/add-step.sh --step "<description>"
```

Appends step with auto-generated ID (S001, S002, etc.).

---

## Update Status

```bash
scripts/update-status.sh --step S001 --status done
```

Valid statuses: `pending`, `in_progress`, `done`, `skipped`.

---

## View Status

```bash
scripts/status.sh [--format json]
```

Shows plan summary and step list.

---

## Archive Plan

```bash
scripts/archive.sh [--force]
```

Moves plan to `.plan/archive/<timestamp>/`.

---

## Validate

```bash
scripts/validate.sh --check all
```

Validates structure, schema, and steps.
