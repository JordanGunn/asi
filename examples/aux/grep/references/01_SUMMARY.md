---
description: Identity and scope of the grep skill.
index:
  - Identity
  - Scope
  - Constraints
---

# Summary

## Identity

grep is a single skill that performs deterministic, auditable text search over a codebase or file tree.
It converts imprecise human intent into explicit ripgrep parameters and executes a portable disk scan.
The output is evidence suitable for surface discovery.

## Scope

grep answers where text patterns appear, which files contain matches, and how many occurrences exist.
It does not explain behavior, architecture, or semantics.
It does not replace reading; it governs when reading starts.

## Constraints

Execution is deterministic and reproducible for a given parameter set.
All search criteria are visible in the invocation and echoed in output.
No hidden state, indexing, or semantic inference is introduced.
