# Templates and Assets

This directory contains deterministic templates used to keep structure consistent and reduce entropy during skill authoring.

## Primary role: entropy control

Beyond pure reference material (for example: images or CSVs), assets are most valuable when they act as epistemic guardrails that constrain the reasoning space.

Common guardrail assets include:

- **Schemas** for inputs, outputs, and persistent state.
- **Templates** for expected artifacts and canonical formats.
- **Controlled vocabularies** (enums) where naming drift causes ambiguity.
- **Fixtures** used for deterministic self-checks and demos.

## What assets are not

- Not a hidden state store that only “the agent knows about”.
- Not a justification for unconstrained scope expansion.
- Not a background maintenance mechanism.

## Safety guidance

- Prefer read-only validation against schemas/templates.
- Keep demo flows deterministic and limited to bundled fixtures; avoid touching external state.

