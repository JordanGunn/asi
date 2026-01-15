# 06_FAILURES.md Template

---
description: Failure conditions, how to surface them, and safe recovery paths.
index:
  - Failure Conditions
  - What to Report
  - Recovery
---

## Failure Conditions

- List common failure cases (missing inputs, missing resources, validation failures).
- Clarify what constitutes “not complete” vs “stop and report failure”.

## What to Report

On failure, reporting should make it easy to identify:

- effective scope
- what was read
- what was written or changed (if any)
- validation status and where it failed

## Recovery

- Provide deterministic recovery paths (which step to rerun, which scope to narrow, which resource to fix).

