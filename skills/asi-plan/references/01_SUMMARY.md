# Summary

## What this skill does

`asi-plan` is the unified kickoff + planning entrypoint.

Depending on what already exists in `.asi/` it will:

- **Kickoff phase (if needed):** create/refine kickoff artifacts until `KICKOFF.md` is `approved`
- **Planning phase (after approval):** produce:

1. **PLAN.md** — Detailed implementation approach
2. **TODO.md** — Ordered task list for execution

It decomposes high-level design into actionable, sequenced work items.

## What problems it solves

- Prevents jumping from kickoff to code
- Forces explicit task decomposition
- Creates auditable trail of planned work
- Enables human review before implementation
- Separates "what to build" from "what's left"

## What this skill is NOT

- Not an implementation skill (no code generation)
- Not a substitute for onboarding/context capture (that is `asi-onboard`)
- Not an execution skill (that is `asi-exec`)
- Not a substitute for human review

## Constraints

- Kickoff must be approved before planning output is generated
- Language-agnostic (no runtime assumptions)
- Dual artifact output (PLAN.md + TODO.md)
- Read-only until artifact write

## Invocation shape

**Primary prompt:**

> "Plan the implementation for [skill-name]"

**Explicit scope inputs:**

- Source KICKOFF.md path (required, must be approved)
- Target directory (optional, defaults to same as KICKOFF.md)
