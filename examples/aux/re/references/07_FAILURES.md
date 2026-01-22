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

### Invalid regex pattern

The pattern has syntax errors.

**Recovery:** Report the syntax error. Suggest a corrected pattern.

### No matches found

The pattern returned zero results.

**Recovery:** Report the empty result with full pattern context. Suggest pattern adjustments.

### Too many matches

Results exceeded budget caps.

**Recovery:** Report truncated results with counts. Suggest narrowing the pattern.

### Timeout exceeded

Pattern execution exceeded time limit.

**Recovery:** Report timeout. Suggest simplifying the pattern or reducing input size.

### Catastrophic backtracking

Pattern causes exponential matching time.

**Recovery:** Reject the pattern. Suggest a non-backtracking alternative.

### Input not found

The specified input file does not exist.

**Recovery:** Fail explicitly. Do not guess alternative paths.

## Recovery

All failures must:

1. Stop execution immediately
2. Report the failure mode explicitly
3. Include the attempted pattern
4. Suggest a specific recovery action
5. Never silently fall back to alternative behavior
