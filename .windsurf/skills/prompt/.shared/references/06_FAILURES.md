---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the prompt skillset.

## Common Failure Cases

### No Artifact Exists

When `./skill.sh status` shows no artifact:

1. Run `./skill.sh init`
2. Begin forge process

### Artifact Not Ready

When attempting to execute with status: draft:

1. Notify user that prompt is not ready
2. Return to forge phase
3. Mark ready when user approves

### Execution Failure

When prompt execution fails:

1. Document the failure
2. Do not delete the artifact
3. Offer to refine and retry

## When to Abort

- User explicitly abandons the prompt
- Prompt objective is no longer relevant
- User requests different approach

## When to Continue

- Refinement iterations are normal
- User uncertainty is expected early
- Multiple forge cycles are acceptable
