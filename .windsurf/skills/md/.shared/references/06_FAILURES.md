---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the md skillset.

## Common Failure Cases

### Source File Not Found

1. Verify the path is correct
2. Check for typos in filename
3. Confirm file is readable

### No H2 Headings (Split)

1. Entire file becomes chunk 00
2. Notify user that no split points found
3. Consider if splitting is appropriate

### Missing Chunks (Merge)

1. Verify all numbered files exist
2. Check manifest for expected files
3. Report missing chunks before proceeding

### Lint Errors

1. Report all findings to user
2. Do not proceed with merge if critical
3. Allow user to fix or override

## When to Abort

- Source file doesn't exist
- No read/write permissions
- Critical lint errors before merge

## When to Continue

- Single-chunk output is valid
- Minor lint warnings (report and proceed)
- Empty sections are preserved
