---
description: Canonical execution path for this skill.
index:
  - Step 1: Validate dependencies
  - Step 2: Validate contract
  - Step 3: Validate forget entries
  - Step 4: Validate expand bundles
  - Step 5: Report staleness
  - CLI
---

# Procedure

## Step 1: Validate dependencies

- Ensure required tooling/runtime is available.

## Step 2: Validate contract

- If `.dtx/CONTRACT.yml` exists, ensure it parses as a mapping.
- Ensure `schema_version` is correct and `working_set` lists are shaped correctly.

## Step 3: Validate forget entries

- If `.dtx/FORGET.yml` exists, ensure entries are parseable and have required fields.

## Step 4: Validate expand bundles

- For each `.dtx/EXPANDS/<EXP-ID>/`, validate presence of `files.txt`, `matches.txt`, and `meta.yml`.
- Recompute `output_hash` from `files.txt` and `matches.txt`.

## Step 5: Report staleness

- If requested via CLI option, compute age from contract `created_at`.

## CLI

From `skills/dtx/dtx-validate/`, run:

```bash
./scripts/skill.sh check
```
