# Example 04: grape skill (progressive disclosure walkthrough)

## Scenario

A user asks, "Where is billing retry logic implemented?" The repository is unfamiliar, the terminology may not match code, and reading files immediately risks tunnel-vision.

## Unconstrained version

The agent opens likely files (e.g., "billing" or "retry" modules) and starts reasoning from partial context. This violates deterministic surface reduction and increases the chance of missing cross-cutting code.

## Deterministic reduction

Use the example skill at `docs/examples/skills/grape/` to bound scope before reading:

1. Treat `/grape <prompt>` as intent.
2. Compile a `grape_surface_plan_v1` and run `scripts/scan.sh`/`scripts/scan.ps1` to get a surface snapshot.
3. Compile the intent into a `grape_compiled_plan_v1` and run `scripts/plan.sh`/`scripts/plan.ps1 --stdin` to validate and execute explicit grep arguments.
4. Use only the returned paths/distribution to choose what to read next.

## Allowed reasoning surface

Reasoning is permitted only for:

- choosing search roots, patterns, globs, and caps based on the prompt and surface snapshot
- widening or narrowing one dimension at a time

Reasoning is not permitted for:

- inferring architecture or correctness from matches alone
- treating empty results as proof of absence

## Progressive disclosure walkthrough (ASI compliance)

Start narrow and follow the declared reference order in `docs/examples/skills/grape/SKILL.md`:

1. `docs/examples/skills/grape/SKILL.md`
   - Minimal body; routes to `metadata.references` only.
   - Matches the canonical `SKILL.md` structure (deterministic surface, no hidden prose).

2. `docs/examples/skills/grape/references/00_ROUTER.md`
   - Deterministic routing: "read all references in order".
   - Makes disclosure order explicit and auditable.

3. `docs/examples/skills/grape/references/01_SUMMARY.md`
   - Explicit scope, constraints, and deterministic execution claims.
   - States search-before-read discipline.

4. `docs/examples/skills/grape/references/02_TRIGGERS.md`
   - Invocation criteria and exit conditions prevent misuse.

5. `docs/examples/skills/grape/references/03_NEVER.md`
   - Prohibitions enforce passivity, no hidden state, no silent bootstrap.

6. `docs/examples/skills/grape/references/04_ALWAYS.md`
   - Invariants enforce deterministic execution and explicit parameters.

7. `docs/examples/skills/grape/references/05_PROCEDURE.md`
   - Deterministic steps and explicit CLI args; search-before-read enforced.
   - Requires schemas/templates from `assets/` to keep plans structured.

8. `docs/examples/skills/grape/references/06_FAILURES.md`
   - Explicit failure semantics and controlled widening steps.

9. `docs/examples/skills/grape/references/07_COMPILER_CONTRACT.md`
   - Deterministic receipts, stable hashes, explicit scope mapping.
   - Guardrails: no timestamps, no implicit scope, no hidden artifacts.

Supporting deterministic assets and enforcement:

- Schemas: `docs/examples/skills/grape/assets/schemas/`
- Templates/examples: `docs/examples/skills/grape/assets/templates/`, `docs/examples/skills/grape/assets/examples/`
- Execution scripts: `docs/examples/skills/grape/scripts/`

## Result

The agent’s first action is bounded discovery, not reading. Scope is declared, execution is auditable, and failures are explicit. Reasoning happens only after deterministic surface reduction.

## What would be non-compliant

- Reading files before running the scan/plan steps.
- Running bootstrap scripts without explicit user permission.
- Changing search terms or scope without reporting it in the compiled plan.
- Presenting empty search results as proof of absence.
