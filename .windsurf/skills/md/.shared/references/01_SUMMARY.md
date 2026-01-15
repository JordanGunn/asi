---
description: What this skill is and is not.
index:
  - What It Does
  - What Problems It Solves
  - What It Is Not
  - Key Invariant
  - Artifact Location
---

# Summary

The **md** skillset manages markdown document workflows with deterministic operations and agent review.

## What It Does

- Splits markdown files by H2 headings (md-split)
- Merges markdown chunks back together (md-merge)
- Lints markdown for structural issues (CLI)
- Reviews markdown for clarity and quality (md-review)

## What Problems It Solves

- Large documents exceeding context limits
- Chunked editing with reassembly
- Ensuring markdown quality and consistency
- Generating navigable document structures

## What It Is Not

- Not for non-markdown formats
- Not for content generation (only structure)
- Not for semantic analysis beyond clarity

## Key Invariant

**Determinism first.** Split, merge, and lint are deterministic. Agent review uses the deterministic outputs as input for subjective quality assessment.

## Artifact Location

Outputs created in the same directory as source by default.
