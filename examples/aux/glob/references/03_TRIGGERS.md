---
description: When this skill activates.
index:
  - Activation
  - Examples
---

# Triggers

## Activation

This skill activates when the user invokes `/glob` followed by a natural language prompt describing what files they want to find.

## Examples

- `/glob find all Python files in the project`
- `/glob list configuration files`
- `/glob show me all markdown documentation`
- `/glob find test files`
- `/glob enumerate all scripts in the repo`

The prompt is treated as intent. The agent compiles it into explicit enumeration parameters.
