# 09. Don’t Use Natural Language as a Crutch for Poor Design

Natural language is a powerful interface. It should not compensate for:

- missing determinism
- undefined schemas/templates
- unbounded discovery
- ambiguous authority

If a rule matters, encode it structurally.   
If a decision matters, constrain it explicitly.

## Natural Language as an Argument

Skill endpoints expose natural language as the primary argument to pre-defined agent-orchestrated operations.  While this is extraordinarily powerful, this creates a very large margin for inconsistent results. If entropy is not controlled at the user-intent ingestion boundary, skills are vulnerable to failure before they begin.

This boundary should **always** be guarded by a reasoning contract implemented via a strict schema asset. This contract should declare the parameters, allowed values, defaults, derivation rules and yield explicit reporting of the derived parameters.

This keeps natural language as the input while preventing hidden or ad hoc reasoning for the core intent of the skill execution begins.
