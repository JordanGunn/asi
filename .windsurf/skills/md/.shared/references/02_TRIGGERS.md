---
description: When to invoke or exit this skill.
index:
  - Invoke When
  - Do Not Invoke When
  - Exit Immediately If
  - Do Not Infer
---

# Triggers

When to activate or exit the md skillset.

## Invoke When

- User has large markdown file to split
- User wants to merge chunked documents
- User requests markdown quality check
- User needs document structure validation

## Do Not Invoke When

- File is not markdown format
- Document is small enough to process whole
- User wants content editing (not structure)

## Exit Immediately If

- Operation completes successfully
- User cancels the operation
- Source files don't exist

## Do Not Infer

- Do not auto-split without user request
- Do not auto-merge without user request
- Do not modify content during operations
