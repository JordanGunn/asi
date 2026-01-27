# Invocation Criteria

## ✅ Invoke when

- User explicitly requests planning for a skill (regardless of whether kickoff exists yet)
- User wants to decompose a kickoff into tasks
- User asks to create PLAN.md or TODO.md from KICKOFF.md
- KICKOFF.md exists with `status: approved` (planning phase will run immediately)

## ❌ Do not invoke when

- User is only trying to build context / read docs (use `asi-onboard`)
- User wants to execute tasks (use `asi-exec`)
- PLAN.md already exists and user has not requested fresh start

## 🛑 Stop immediately if

- KICKOFF.md cannot be parsed
- KICKOFF.md is missing required sections
- User cannot confirm source KICKOFF.md path
- Target directory is not writable
- User withdraws consent mid-procedure
