---
description: Failure cases and how to respond.
index:
  - Empty results
  - Too many results
  - Tooling failures
---

# Failures

## Empty results

- Report that results are empty without concluding non-existence.
- Propose one controlled widening action (root, glob, term, mode, case).

## Too many results

- Narrow one dimension at a time (add a glob, refine term, reduce roots).
- Prefer narrowing scope over adding more expansions.

## Tooling failures

- If required tooling is missing, run `grape validate` and report the missing dependency.
- Do not attempt installation unless explicitly requested by the user.

## Plan validation failures

- If `grape plan --stdin` fails validation, report the first schema errors and stop.
- Do not run `grape grep` until a valid compiled plan is provided.

## Bootstrap required

- If `grape validate` reports a missing venv or dependency, stop and ask for permission to run
  `bootstrap.sh`/`bootstrap.ps1`.
