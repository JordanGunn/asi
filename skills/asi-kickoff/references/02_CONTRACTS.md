# Reasoning Contracts

## Contract declaration

This skill uses a single reasoning contract: the **Kickoff Intent Contract**.

## Kickoff Intent Contract

The agent must derive structured intent from the user's natural-language request.

**Schema:** `assets/schemas/kickoff_v1.schema.json`

### Required derivations

| Field              | Source                 | Constraint                    |
| ------------------ | ---------------------- | ----------------------------- |
| `skill_name`       | User prompt            | Must be explicitly stated     |
| `skill_purpose`    | User prompt            | Must be explicitly stated     |
| `target_directory` | User prompt or default | Defaults to working directory |

### Disallowed derivations

- Do not infer `skill_name` from context
- Do not infer `skill_purpose` from similar skills
- Do not expand scope beyond what is explicitly requested

## Output contract

The skill produces a single artifact: `KICKOFF.md`

**Template:** `assets/templates/KICKOFF.template.md`

### Required frontmatter fields

| Field           | Type     | Purpose                                              |
| --------------- | -------- | ---------------------------------------------------- |
| `description` | string | One-line summary of the kickoff |
| `timestamp` | ISO 8601 | Creation timestamp |
| `status` | enum | `draft` &#124; `review` &#124; `approved` &#124; `rejected` |
| `skill_name` | string | Target skill being designed |
| `skill_purpose` | string | Declared purpose of target skill |

### Required body sections

1. Purpose
2. Deterministic Surface
3. Judgment Remainder
4. Schema Designs
5. Open Questions
