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
