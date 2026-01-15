---
description: When to invoke or exit this skill.
index:
  - Invoke When
  - Do Not Invoke When
  - Exit Immediately If
  - Do Not Infer
---

# Triggers

When to activate or exit the md-split skill.

## Invoke When

- User has a large markdown file to split
- User wants section-level chunking
- Document exceeds comfortable reading/processing size
- User explicitly requests splitting

## Do Not Invoke When

- File is small enough to process whole
- User wants to merge files (not split)
- File is not markdown format
- User wants different split granularity (H3, paragraphs)

## Exit Immediately If

- Split completes successfully
- User cancels the operation
- Source file doesn't exist

## Do Not Infer

- Do not auto-split without user request
- Do not assume splitting is wanted
- Do not split files not specified by user
