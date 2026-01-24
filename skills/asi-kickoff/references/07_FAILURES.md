# Failure Conditions

## Halt and report failure if

- Skill name cannot be determined from user input
- Skill purpose cannot be determined from user input
- ASI kickoff documents are missing or unreadable
- Target directory does not exist or is not writable
- User withdraws consent during procedure
- Required dependencies are missing (e.g., `jq`)

## Missing dependencies

If required command-line dependencies are missing (for example, `jq`):

1. Halt and report which command is missing
2. Suggest the user run `scripts/bootstrap.sh --check` (user-run helper) for install guidance
3. Do not attempt to install dependencies automatically

## Existing kickoff

If `KICKOFF.md` already exists:

1. Report its existence and frontmatter status
2. Ask user for explicit instruction:
   - **Review**: Read and summarize existing kickoff
   - **Replace**: Delete and start fresh (requires explicit consent)
   - **Abort**: Exit without changes

Do not overwrite without explicit consent.

## Partial completion

If procedure is interrupted:

1. Report which steps completed
2. Report which steps remain
3. Do not produce partial KICKOFF.md
4. Suggest resumption path

## Ambiguity failures

If requirements are ambiguous:

1. Capture ambiguity as open question
2. Do not infer or speculate
3. Report ambiguity to user
4. Proceed only if user provides clarification

## Recovery

This skill does not auto-recover. Failures require user intervention.

Failure is an acceptable outcome — it surfaces hidden assumptions rather than hiding them.
