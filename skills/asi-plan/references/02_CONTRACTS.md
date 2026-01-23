# Reasoning Contracts

## Contract declaration

This skill uses the **Plan Intent Contract** and ingests kickoff artifacts.

## Input Artifacts (from asi-kickoff)

The skill reads from `.asi/kickoff/`:

| Artifact | Schema | Purpose |
| -------- | ------ | ------- |
| `KICKOFF.md` | — | High-level design, must be `status: approved` |
| `SKILL_TYPE.json` | `skill_type_v1.schema.json` | Single or grouped skill decision |
| `SCAFFOLD.json` | `*_scaffold_v1.schema.json` | Directory structure to create |

## Plan Intent Contract

The agent must derive structured intent from kickoff artifacts.

**Schema:** `assets/schemas/plan_v1.schema.json`

### Required derivations

| Field | Source | Constraint |
| ----- | ------ | ---------- |
| `kickoff_path` | Fixed | `.asi/kickoff/KICKOFF.md` |
| `skill_type_path` | Fixed | `.asi/kickoff/SKILL_TYPE.json` |
| `scaffold_path` | Fixed | `.asi/kickoff/SCAFFOLD.json` |

### Validation before proceeding

- `.asi/kickoff/KICKOFF.md` must exist with `status: approved`
- `.asi/kickoff/SKILL_TYPE.json` must exist and be valid
- `.asi/kickoff/SCAFFOLD.json` must exist and be valid

### Disallowed derivations

- Do not proceed if KICKOFF.md status is not `approved`
- Do not infer tasks not traceable to KICKOFF.md or SCAFFOLD.json
- Do not expand scope beyond KICKOFF.md boundaries
- Do not modify kickoff artifacts

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
