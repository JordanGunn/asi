# Glossary

- **Agent:** The interpreter that evaluates user testimony, reasons, and decides whether to invoke skills.
- **Artifact:** A declared output used as a completion signal.
- **ASI (Agent Skill Interface):** A behavioral contract that governs sequencing (determinism before reasoning), passivity, observability, and failure.
- **Determinism / Deterministic:** Producing the same result given the same inputs, without variation. In ASI, deterministic operations are preferred wherever possible to ensure repeatability and auditability.
- **Deterministic discovery:** Enumeration of the complete input universe in a repeatable way.
- **Deterministic narrowing:** Read-only reduction of scope over a discovered universe without guessing.
- **Deterministic surface reduction:** Discovery + narrowing that bounds what the agent may reason over.
- **Failure semantics:** The rules for how failure is detected and surfaced (fail loudly; no silent degradation).
- **Judgment contract:** Constrains output discretion after deterministic execution; governs selection, framing, and recommendations. Distinct from reasoning contracts which handle input.
- **Passive behavior:** Observe/report without acting; no auto-repair or background mutation.
- **Qualitative judgment:** Subjective decisions made by agents when determinism cannot reasonably or appropriately provide a solution. Bounded by reasoning contracts.
- **Quantitative outcome:** Deterministic results produced by tools or scripts; factual data that does not require interpretation.
- **Reasoning contract:** An explicit declaration of when and how an agent may derive parameters or make decisions from natural-language input. Contracts constrain subjective reasoning to auditable bounds.
- **Skill:** A policy-gated entry point to capability; the atomic unit of invocable behavior in ASI.
- **Subjective reasoning:** Agent inference that involves judgment, interpretation, or choice among valid alternatives. ASI constrains subjective reasoning to occur only after deterministic surface reduction.
- **Validation:** Deterministic proof that declared artifacts/invariants hold.
