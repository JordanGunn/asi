# Invocation Criteria

## ✅ Invoke when

- User explicitly requests planning for a skill with approved KICKOFF.md
- User wants to decompose a kickoff into tasks
- User asks to create PLAN.md or TODO.md from KICKOFF.md
- KICKOFF.md exists with `status: approved`

## ❌ Do not invoke when

- KICKOFF.md does not exist (use `asi-kickoff` first)
- KICKOFF.md status is `draft` or `review` (await approval)
- KICKOFF.md status is `rejected` (revise kickoff first)
- User wants to execute tasks (use `asi-exec`)
- User wants to modify KICKOFF.md (use `asi-kickoff`)
- PLAN.md already exists and user has not requested fresh start

## 🛑 Stop immediately if

- KICKOFF.md cannot be parsed
- KICKOFF.md is missing required sections
- User cannot confirm source KICKOFF.md path
- Target directory is not writable
- User withdraws consent mid-procedure
