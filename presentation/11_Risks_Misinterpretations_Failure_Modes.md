# Risks, Misinterpretations, Failure Modes

<!-- fit -->

## Risks (what can go wrong)

- Over-broad scope → high cost, inconsistent results
- “Helpful” improvisation → non-auditable drift
- Silent mutation → trust collapse
- “Looks done” output without validation

## Common misinterpretations

- “A skill is just a prompt”
- “A skill will run automatically”
- “More instructions = more reliability”

## Common failure modes (operational)

- Missing references/assets/scripts, but the agent proceeds anyway
- No explicit **NEVER/ALWAYS** boundaries
- No deterministic discovery/narrowing step
- No explicit stop conditions (“fail loudly”)

<!--
Speaker notes:
- Manifesto tie-in: “If nothing happens, that can be correct.” (`docs/manifesto/09_NO_PROMISES.md`)
-->
