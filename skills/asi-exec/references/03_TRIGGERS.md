# Invocation Criteria

## ✅ Invoke when

- User explicitly requests task execution
- PLAN.md exists with `status: approved`
- TODO.md exists with pending tasks
- No drift detected in upstream artifacts
- User asks to "implement", "build", "execute", or "run" a task

## ❌ Do not invoke when

- PLAN.md does not exist (use `asi-plan` first)
- PLAN.md status is not `approved` (await approval)
- TODO.md does not exist (use `asi-plan` first)
- All tasks are already `done`
- Drift detected (resolve drift first)
- User wants to modify PLAN.md (use `asi-plan`)
- User wants to add tasks (modify TODO.md manually or re-plan)

## 🛑 Stop immediately if

- Drift detected during execution
- Task dependencies not satisfied
- User withdraws consent
- Execution error occurs (report and halt)
- Task cannot be completed without external input
- PLAN.md or TODO.md becomes unreadable
