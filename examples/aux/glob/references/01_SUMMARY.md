---
description: Identity and scope of the glob skill.
index:
  - Identity
  - Scope
  - Constraints
---

# Summary

## Identity

glob is a single skill that performs deterministic, auditable file enumeration over a directory tree.
It converts imprecise human intent into explicit fd parameters and executes a portable disk scan.
The output is a list of file paths suitable for surface discovery.

## Scope

glob answers which files exist, what types are present, and how the directory tree is structured.
It does not read file contents, explain behavior, or analyze semantics.
It does not replace exploration; it governs where exploration starts.

## Constraints

Execution is deterministic and reproducible for a given parameter set.
All search criteria are visible in the invocation and echoed in output.
No hidden state, indexing, or semantic inference is introduced.
