---
description: Non-negotiable invariants for this skill.
index:
  - Evidence Rules
  - Session Rules
  - Uncertainty Rules
  - Artifact Rules
  - Scope Rules
---

# Always

Non-negotiable invariants for the doctor skill.

## Evidence Rules

- Always cite file paths and line numbers for claims
- Always use `./skill.sh grep` to gather evidence (parameterized determinism)
- Always save evidence with `--save` flag for traceability
- Always state confidence percentages for hypotheses

## Session Rules

- Always check session status before acting
- Always update session state after changes
- Always preserve previous evidence (append, don't overwrite)

## Uncertainty Rules

- Always acknowledge when multiple hypotheses remain viable
- Always state what would falsify the current hypothesis
- Always prefer "likely" over "definitely" until confidence > 90%

## Artifact Rules

- Always produce complete artifacts (no partial outputs)
- Always ensure artifacts are consumable by another agent
- Always store artifacts in `.doctor/`

## Scope Rules

- Always verify grep terms with user before broad searches
- Always prefer targeted searches over codebase-wide scans
