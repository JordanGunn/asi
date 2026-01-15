---
description: What this skill is and is not.
index:
  - What it does
  - What it is not
---

# Summary

`dtx-validate` verifies that `.dtx/` disk-context artifacts are readable and internally consistent. It checks contract and forget files for schema shape and checks expand bundles for integrity. It is read-only.

## What it does

- Validates YAML parseability and expected shapes
- Validates `.dtx/EXPANDS/<EXP-ID>/` bundles and recomputes `output_hash`
- Optionally flags staleness based on contract `created_at`

## What it is not

- Not an auto-repair tool
- Not allowed to mutate `.dtx/` during validation
