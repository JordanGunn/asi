# Reasoning Contracts

## Intent Contract

Before executing any script, the agent derives structured intent.

**Schema:** `assets/schemas/plan_intent_v1.schema.json`

### Required derivations

| Field | Source | Constraint |
|-------|--------|------------|
| `action` | User request | Must be: create, add-step, update-status, status, archive |
| `plan_name` | User request | Required for create |
| `step_description` | User request | Required for add-step |
| `step_id` | User request or context | Required for update-status |
| `new_status` | User request or context | Required for update-status |

## Result Contract

After script execution, validate the output receipt.

**Schema:** `assets/schemas/plan_result_v1.schema.json`

## Plan Artifact Contract

The active plan must conform to schema.

**Schema:** `assets/schemas/plan_v1.schema.json`
