# Step 3 — Design Reasoning Schemas as Static Assets

Using the judgment items from Step 2, design **strict schemas** that constrain reasoning.

## Core Principle

**Anytime agent inference is required, a reasoning schema MUST be proposed and implemented.**

The schema:

1. **Defines the shape** of the decision
2. **Constrains agent output** to a declared structure
3. **Produces an artifact** that downstream stages inspect or ingest

This controls entropy and makes inference auditable.

```text
Inference Point → Reasoning Schema → Artifact → Downstream Ingestion
```

## Required Schema Types

### Intent Schema

What the agent believes it is being asked to do.

### Execution Plan Schema

Derived parameters, scope, and intended actions.

### Result / Receipt Schema

What was actually executed and observed.

### Scaffolding Schemas (for skill creation)

When creating skills, additional schemas constrain structural decisions:

* **Skill Type Schema** — single skill or grouped skills?
* **Single Skill Scaffold Schema** — skill name, directory structure
* **Grouped Skill Scaffold Schema** — prefix, sub-skill names, directory structures

These produce artifacts that `asi-plan` inspects and `asi-exec` ingests.

## Schema Constraints

* Schemas define **shape**, not logic
* No defaults that hide uncertainty
* Absence must be representable as data
* Schemas must be **host-agnostic**

  * no protocol assumptions
  * no IDE assumptions
  * no implicit environment or runtime coupling

## Artifact Production

Every reasoning schema MUST produce an output artifact:

| Schema | Artifact | Inspected By | Ingested By |
| ------ | -------- | ------------ | ----------- |
| Intent | embedded in KICKOFF.md | asi-plan | — |
| Skill Type | SKILL_TYPE.json | asi-plan | — |
| Scaffold | SCAFFOLD.json | asi-plan | asi-exec |
| Execution Plan | PLAN.md | asi-exec | — |
| Receipt | RECEIPT.md or receipt.json | user, validation | — |

Agents must never reason without a declared schema.
Agents must never infer without producing an artifact.
