# Example 01: Surface Reduction

## Scenario

A user says: “Check all the files with postgres in them and tell me what to change.”

## Unconstrained version (non-compliant)

- The agent “mentally” ranges over the entire repository.
- The agent selects files implicitly (“these seem relevant”).
- The agent produces recommendations without an explicit scope.

This fails ASI because reasoning occurs before deterministic surface reduction.

## Deterministic reduction (ASI-compliant shape)

1. **Deterministic discovery:** enumerate the universe (e.g., all files in a defined root that match a declared, repeatable selection rule).
2. **Deterministic narrowing:** filter that universe by a concrete predicate (e.g., exact substring match `postgres`, or a declared pattern).
3. **Allowed reasoning surface:** only after narrowing, interpret the matches and propose changes.

## Result (what gets reported)

- Effective scope: the discovered file universe and the narrowed match set.
- What was read: the concrete files and sections surfaced by narrowing.
- Recommendations: grounded in the surfaced content.

## What would be non-compliant

- Expanding to “similar files” without reporting scope widening.
- Skipping discovery/narrowing and reasoning across the whole repo.
