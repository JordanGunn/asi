# Determinism-before-Reasoning Ordering

## Canonical ordering

1. Deterministic discovery: define the complete universe of inputs.
2. Deterministic narrowing: reduce scope read-only without guessing.
3. Deterministic execution: act only on the narrowed surface.
4. Deterministic validation: prove declared artifacts and invariants.
5. Subjective reasoning: interpret validated state.
6. Artifact creation: record outputs and decisions for humans.

## Common violations

- Reasoning over an entire repository before enumerating and narrowing scope.
- Using “seems relevant” as a scope selector.
- Explaining around missing artifacts instead of returning to deterministic steps.

