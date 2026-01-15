---
description: Identity and scope of the grape skill.
index:
  - Identity
  - Scope
  - Constraints
---

# Summary

## Identity

grape is a single skill that performs deterministic, auditable search over a codebase.
It converts imprecise human intent into explicit search parameters and executes a portable disk scan.
The output is evidence suitable for surface discovery.

## Scope

grape answers where things might live, which files or domains are involved, and whether a term appears at all.
It does not explain behavior, architecture, or semantics.
It does not replace reading; it governs when reading starts.

## Constraints

Execution is deterministic and reproducible for a given parameter set.
All search criteria are visible in the invocation and echoed in output.
No hidden state, indexing, or semantic inference is introduced.
