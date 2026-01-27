# Summary

## What this skill does

`asi-kickoff` executes the ASI Skill Design Kickoff procedure to produce a high-level planning artifact (`KICKOFF.md`) for a new skill.

Note: `asi-plan` now includes a kickoff phase. Use `asi-kickoff` when you explicitly want kickoff-only behavior, without entering planning.

It guides structured thinking through:

- Purpose definition
- Deterministic surface mapping
- Judgment remainder identification
- Schema design (shape only)
- Open questions capture

## What problems it solves

- Prevents premature implementation
- Forces explicit separation of determinism vs judgment
- Captures ambiguity before it becomes hidden assumption
- Produces a reviewable artifact before code is written

## What this skill is NOT

- Not an implementation skill (no code generation)
- Not a planning decomposition skill (that is `asi-plan`)
- Not an execution skill (that is `asi-exec`)
- Not a substitute for human review

## Constraints

- Language-agnostic (no runtime assumptions)
- Deterministic-first (maximize mechanical guarantees)
- Single artifact output (`KICKOFF.md`)
- Read-only until artifact write

## Invocation shape

**Primary prompt:**

> "Kickoff a new skill design for [skill-name]"

**Explicit scope inputs:**

- Target skill name (required)
- Target skill purpose (required)
- Target directory (optional, defaults to working directory)
