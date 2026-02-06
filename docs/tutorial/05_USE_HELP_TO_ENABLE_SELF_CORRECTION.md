# Use Help to Enable Self-Correction

## Goal

- design help output so an agent can recover quickly from mistakes without extra guesswork.

## Why This Matters

- help is a deterministic recovery surface when invocation assumptions fail.
- correction-friendly help reduces retry churn and invalid parameter loops.

## What To Do

- define complete command list and stable usage forms.
- include option semantics, required inputs, defaults, and focused examples.
- design errors to route back to valid usage paths.

## What To Avoid

- missing required flags or implicit defaults.
- ambiguous option semantics (for example, mixing file globs and content patterns).
- examples that contradict schema or runtime behavior.

## Governance Tie-In

This step protects self-correction quality and limits agent guesswork under failure.

## Normative References

- `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`
- `docs/design/principles/07_LANGUAGE_NOT_A_CRUTCH.md`
- `docs/implementation/04_MAINTAINER_COMPLIANCE_CHECKLIST.md`

## Checkpoint

- Evidence required: one invalid invocation, associated help excerpt, and corrected invocation.
- Pass condition: corrected invocation is derived solely from help output without undocumented assumptions.
- Common failure signal: retry relies on guessed options not present in help.
