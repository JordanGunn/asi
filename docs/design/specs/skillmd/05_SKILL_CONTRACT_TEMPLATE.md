# Skill Contract Template

This template is a fill-in skeleton for writing a skill contract that is compatible with ASI-style governance (determinism before reasoning, strict passivity, and explicit failure semantics).

The intent is to make the skill’s surface:

- explicit (inputs and scope are named)
- deterministic where possible (discovery/narrowing before interpretation)
- auditable (what was considered, read, changed, and validated)

## Template

Use the headings below as a starting point when authoring a skill’s reference docs.

### Purpose

- What this skill is for.
- What this skill is not for (to prevent scope creep).

### Inputs

- Primary argument: a user prompt (natural language).
- Optional: additional structured parameters provided by the hosting environment (if any). If present, treat them as explicit scope/execution controls and report them.
- Any derived parameters (scope, filters, patterns, targets) that determine execution.
- Defaults (if any) and how they affect derived scope.
- What conditions widen scope, and how that widening is reported.
- If frontmatter is used, how `metadata.references`, `metadata.scripts`, `metadata.assets`, and `metadata.artifacts` relate to these inputs.

### Deterministic surface reduction

- How the input universe is defined (deterministic discovery).
- How the universe is narrowed (deterministic narrowing).
- What the agent is allowed to interpret only after narrowing.

### Artifacts and validation

- What artifacts are expected to exist on success (if any).
- What validation proves completion.
- What happens if validation fails.
- Optional: whether the skill includes deterministic self-checks (validation and/or demo) that operate only on bundled assets/fixtures.

### Prohibitions

- Forbidden scope expansions.
- Forbidden background behavior or auto-actions.
- Forbidden partial success presentations.

### Failure semantics

- What conditions cause the skill to stop and report failure.
- What constitutes “non-completion” vs “hard failure”.
- What information is included in failure output.

### Observability

The skill’s execution and/or reporting should make it easy to answer:

- effective scope: what was considered in-bounds
- what was read: inputs consulted
- what was written or changed: mutation surface
- validation status: pass/fail for declared artifacts/invariants

## Minimal example (illustrative)

```text
Purpose:
  Create a report of X for a user-selected scope. Not a mutation tool.

Inputs:
  root_path, include_patterns, exclude_patterns

Deterministic surface reduction:
  Discovery: enumerate files under root_path using include/exclude rules.
  Narrowing: filter discovered files by an explicit predicate.
  Interpretation: summarize only the narrowed set.

Artifacts and validation:
  Artifact: report file exists.
  Validation: report contains a header and a non-empty results section.

Prohibitions:
  No file edits. No background runs. No silent scope widening.

Failure semantics:
  If discovery yields zero files, fail with an explicit explanation.

Observability:
  Report effective scope, read set, changed set (none), and validation status.
```
