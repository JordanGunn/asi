---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the md-split skill.

## Common Failure Cases

### Source File Not Found

When the specified file doesn't exist:

1. Verify the path is correct
2. Check for typos in filename
3. Confirm file is readable

### No H2 Headings

When the file has no H2 sections:

1. The entire file becomes chunk 00
2. Notify user that no split points found
3. Consider if H3 splitting is needed (not supported)

### Output Directory Issues

When output directory has problems:

1. Check write permissions
2. Create directory if it doesn't exist
3. Warn about existing files that would be overwritten

## When to Abort

- Source file doesn't exist
- No read permissions
- Output directory not writable

## When to Continue

- Single-chunk output is valid (no H2s found)
- Empty sections are preserved
- Existing index will be regenerated
