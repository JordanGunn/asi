# Prompt Artifact Schema

Defines the canonical structure for prompt artifacts in the ASI-compliant prompt skills.

## Version: 1.0

### Required Fields

- `version`: string - Schema version (must be "1")
- `status`: enum - Artifact status ("drafting", "ready", "executed")
- `created_at`: string - RFC3339 timestamp of creation
- `updated_at`: string - RFC3339 timestamp of last update

### Intent Object (required)

- `objective`: string - Clear statement of what the prompt aims to achieve
- `constraints`: array of strings - List of constraints and limitations
- `assumptions`: array of strings - Explicit assumptions being made
- `open_questions`: array of strings - Unresolved questions that block readiness

### Content Fields

- `prompt`: string - The actual prompt text
- `quality`: object | null - Quality metrics when present

### Quality Object (optional)

- `clarity_score`: number (0-1) - Subjective clarity rating
- `completeness_score`: number (0-1) - Subjective completeness rating
- `validated_at`: string - RFC3339 timestamp when quality was assessed

### Validation Rules

1. All required fields must be present
2. All timestamps must be valid RFC3339 format
3. Status must be one of the allowed enum values
4. When status is "ready", open_questions must be empty
5. When status is "executed", prompt must not be empty
