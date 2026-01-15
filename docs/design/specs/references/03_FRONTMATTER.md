# Reference Frontmatter

Reference frontmatter should be included in reference files to:

1. Provide additional metadata about the reference.
2. Enable deterministic anchor-level routing.
3. Describe the reference file content.

---

## Fields

### Required

#### `description`

A short description of the reference file purpose and intents.

#### `index`

A flat list of H2 anchors in the reference file for section-level routing.

**Constraints:**

- Only H2 headers are indexed (H3+ navigated naturally by agent)
- Entries must match actual H2 headers in the file body
- Order should reflect document structure

### Optional

#### `summary`

A short summary of the reference file purpose and intents.

**Character limit:** 256

#### `tags`

A list of tags that can be used to search for the reference file.

---

## Example

```yaml
description: Canonical execution path for the skill.
summary: Step-by-step procedure from inputs to outputs.
tags:
  - procedure
  - execution
  - steps
index:
  - Inputs
  - Steps
  - Outputs
  - Checkpoints
```

## Utilization guidance (implementation-facing)

### Using `description`

- Treat `description` as a concise, human-readable purpose string for the reference.
- Prefer using it in reporting (for example: “loaded 06_PROCEDURE.md — Canonical execution path for the skill”) rather than as a logic input.

### Using `index`

- Treat `index` as a deterministic navigation aid for H2 sections.
- If a router uses `Goto`, prefer jumping only to anchors that exist in the reference body and are listed in `index`.
- If `index` is missing or stale, prefer failing loudly (or falling back to reading the whole file) rather than guessing section names.

### Using optional fields (`summary`, `tags`)

- Treat optional fields as discovery aids, not as behavioral controls.
- They should not be used to justify scope expansion or implicit auto-actions.
