# Reasoning Contracts

## Contract declaration

This skill uses a single reasoning contract: the **Plan Intent Contract**.

## Plan Intent Contract

The agent must derive structured intent from the user's request and KICKOFF.md content.

**Schema:** `assets/schemas/plan_v1.schema.json`

### Required derivations

| Field | Source | Constraint |
| ----- | ------ | ---------- |
| `source_kickoff` | User prompt or context | Must point to approved KICKOFF.md |
| `target_directory` | User prompt or default | Defaults to KICKOFF.md directory |

### Disallowed derivations

- Do not proceed if KICKOFF.md status is not `approved`
- Do not infer tasks not traceable to KICKOFF.md
- Do not expand scope beyond KICKOFF.md boundaries

## Output contracts

The skill produces two artifacts:

### PLAN.md

**Template:** `assets/templates/PLAN.template.md`

#### Required frontmatter fields

| Field | Type | Purpose |
| ----- | ---- | ------- |
| `description` | string | One-line summary |
| `timestamp` | ISO 8601 | Creation timestamp |
| `status` | enum | `draft` &#124; `review` &#124; `approved` &#124; `rejected` |
| `source_kickoff` | string | Path to source KICKOFF.md |
| `skill_name` | string | Target skill being planned |

#### Required body sections

1. Scripts
2. Assets
3. Validation
4. Boundaries
5. Non-goals
6. Risks
7. Lifecycle

### TODO.md

**Template:** `assets/templates/TODO.template.md`

#### Required frontmatter fields

| Field | Type | Purpose |
| ----- | ---- | ------- |
| `description` | string | One-line summary |
| `timestamp` | ISO 8601 | Creation timestamp |
| `status` | enum | `draft` &#124; `review` &#124; `approved` &#124; `rejected` |
| `source_plan` | string | Path to source PLAN.md |

#### Required body structure

- Ordered task list with:
  - Task ID
  - Description
  - Status (`pending` &#124; `in_progress` &#124; `done`)
  - Dependencies (optional)
  - Source section reference
