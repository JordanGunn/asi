# Failure Conditions

## Halt and report failure if

- PLAN.md does not exist
- PLAN.md status is not `approved`
- TODO.md does not exist
- Drift detected (PLAN.md changed since TODO.md created)
- Task dependencies not satisfied
- Execution error occurs
- User withdraws consent

## Plan not approved

If PLAN.md exists but status is not `approved`:

1. Report current status
2. Explain that execution requires approved plan
3. Suggest submitting PLAN.md for review/approval
4. Do not proceed

## Drift detected

If PLAN.md hash doesn't match stored hash:

1. Report the drift detection
2. Explain cascade invalidation:
   - PLAN.md changed → TODO.md may be stale
3. Suggest options:
   - **Re-plan**: Run `asi-plan` to regenerate TODO.md
   - **Accept drift**: User explicitly acknowledges (updates hash)
4. Do not proceed without resolution

## All done

If all tasks have `status: done`:

1. Report completion summary
2. List all tasks executed
3. Suggest next steps (if any)
4. This is success, not failure

## Execution error

If task execution fails:

1. Update task status to `in_progress` (leave as-is, not done)
2. Report error details
3. Report partial progress (artifacts created so far)
4. Await user direction:
   - **Retry**: Attempt task again
   - **Skip**: Mark task skipped, proceed to next
   - **Abort**: Stop execution entirely
   - **Rollback**: Remove artifacts created during failed attempt (recommended)

### Rollback recommendation

When a task fails mid-execution, rollback is recommended:

1. Track all files created during task execution
2. If user requests rollback, delete created files
3. Restore modified files from backup (if available)
4. Reset task status to `pending`
5. Log rollback action in RECEIPT.md

## Dependency blocked

If task dependencies not satisfied:

1. Report which dependencies are blocking
2. Report their current status
3. Suggest executing dependencies first
4. Do not proceed with blocked task

## Blocked status

If a task requires external input or is waiting on external factors:

1. Update task status to `blocked`
2. Document what the task is waiting for
3. Proceed to next non-blocked, non-dependent task
4. Report blocked tasks in execution summary

## Concurrency handling

To prevent concurrent execution conflicts:

1. Check for `.asi-exec.lock` file before execution
2. If lock exists and is stale (>1 hour), remove it with warning
3. If lock exists and is fresh, halt with "Execution in progress" message
4. Create lock file at execution start: `{timestamp, task_id, pid}`
5. Remove lock file at execution end (success or failure)

This prevents race conditions when multiple agents or sessions attempt execution.

## Recovery

This skill does not auto-recover. Failures require user intervention.

Failure is an acceptable outcome — it surfaces issues rather than masking them.
