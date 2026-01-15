---
description: Non-negotiable invariants for this skill.
index:
  - Artifact Rules
  - Forge Rules
  - Execution Rules
  - CLI Rules
---

# Always

Non-negotiable invariants for the prompt skillset.

## Artifact Rules

- Always store artifacts in `.prompt/`
- Always use YAML format for active.yaml
- Always include frontmatter with status field
- Always preserve artifact after execution (write receipt instead)

## Forge Rules

- Always reflect understanding back to user before finalizing
- Always confirm readiness before marking status: ready
- Always iterate until user approves

## Execution Rules

- Always verify status: ready before executing
- Always quote the prompt before execution
- Always write an execution receipt after success
- Always get explicit user consent for execution

## CLI Rules

- Always use `./skill.sh status` to check current state
- Always use `./skill.sh validate` before operations
