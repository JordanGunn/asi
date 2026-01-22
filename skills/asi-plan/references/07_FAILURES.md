# Failure Conditions

## Halt and report failure if

- KICKOFF.md does not exist
- KICKOFF.md status is not `approved`
- KICKOFF.md is missing required sections
- KICKOFF.md frontmatter is invalid
- Target directory does not exist or is not writable
- User withdraws consent during procedure

## Kickoff not approved

If KICKOFF.md exists but status is not `approved`:

1. Report current status
2. Explain that planning requires approved kickoff
3. Suggest:
   - **Review**: If status is `draft`, suggest submitting for review
   - **Revise**: If status is `rejected`, suggest revising kickoff
   - **Wait**: If status is `review`, suggest awaiting approval
4. Do not proceed

## Existing plan

If PLAN.md or TODO.md already exists:

1. Report their existence and frontmatter status
2. Ask user for explicit instruction:
   - **Review**: Read and summarize existing artifacts
   - **Replace**: Delete and regenerate (requires explicit consent)
   - **Abort**: Exit without changes

Do not overwrite without explicit consent.

## Partial completion

If procedure is interrupted:

1. Report which steps completed
2. Report which artifacts were produced (if any)
3. Do not produce partial artifacts
4. Suggest resumption path

## KICKOFF.md changed

If KICKOFF.md is modified during or after planning:

1. Flag the change via chrono awareness (timestamp/hash comparison)
2. Reason about whether PLAN.md needs modification to align
3. If KICKOFF.md is invalidated:
   - PLAN.md is invalidated
   - TODO.md is invalidated
4. Recommend user review the cascade impact

**Cascade rule:** KICKOFF → PLAN → TODO. Upstream invalidation cascades downstream.

## Recovery

This skill does not auto-recover. Failures require user intervention.

Failure is an acceptable outcome — it surfaces issues rather than hiding them.
