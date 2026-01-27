# Failure Conditions

## Halt and report failure if

- KICKOFF.md is missing required sections
- KICKOFF.md frontmatter is invalid
- Target directory does not exist or is not writable
- User withdraws consent during procedure
- Required dependencies are missing (e.g., `jq`)

## Missing dependencies

If required command-line dependencies are missing (for example, `jq`):

1. Halt and report which command is missing
2. Suggest the user run `scripts/bootstrap.sh --check` (user-run helper) for install guidance
3. Do not attempt to install dependencies automatically

## Kickoff missing / not approved (kickoff phase required)

If KICKOFF.md does not exist, or exists but status is not `approved`:

1. Report the current state (missing vs current status)
2. Explain that `asi-plan` will run the kickoff phase first
3. Use the kickoff-phase scripts from this skill:
   - `scripts/kickoff-init.sh --skill-name "<name>" --skill-purpose "<purpose>"`
   - Progress steps via `scripts/kickoff-checkpoint.sh`
   - Mark approval via `scripts/kickoff-approve.sh`
4. After approval, resume the planning phase with `scripts/init.sh`

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
