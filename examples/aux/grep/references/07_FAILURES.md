---
description: Failure modes and recovery paths.
index:
  - Failure Modes
  - Recovery
---

# Failures

## Failure Modes

### Schema validation failed

The compiled plan does not match the schema.

**Recovery:** Fix the plan structure. Do not execute.

### No matches found

The search returned zero results.

**Recovery:** Report the empty result with full scope context. Suggest one widening axis (broader pattern, different file types, relaxed case).

### Too many matches

Results exceeded budget caps.

**Recovery:** Report truncated results with counts. Suggest narrowing axes (more specific pattern, tighter globs, smaller scope).

### Root directory not found

The specified root does not exist.

**Recovery:** Fail explicitly. Do not guess alternative paths.

### Tool not available

ripgrep (`rg`) is not installed or not in PATH.

**Recovery:** Report the missing dependency. Do not attempt workarounds.

### Permission denied

Cannot read files in the target directory.

**Recovery:** Report the error. Do not escalate privileges or retry.

## Recovery

All failures must:

1. Stop execution immediately
2. Report the failure mode explicitly
3. Include the attempted parameters
4. Suggest a specific recovery action
5. Never silently fall back to alternative behavior
