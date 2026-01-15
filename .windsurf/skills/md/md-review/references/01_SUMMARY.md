---
description: What this skill is and is not.
index:
  - What It Does
  - What It Is Not
  - Key Pattern
---

# Summary

The **md-review** skill provides agent-driven quality assessment for markdown documents.

## What It Does

- Runs deterministic lint first (CLI)
- Reviews document structure and clarity
- Assesses heading hierarchy and flow
- Identifies confusing or unclear sections
- Provides actionable improvement suggestions

## What It Is Not

- Not for content editing (review only)
- Not for style preferences (objective quality)
- Not a replacement for lint (complements it)

## Key Pattern

**Determinism first.** Always run `./skill.sh lint` before review. The lint output provides objective findings; the review adds subjective quality assessment.
