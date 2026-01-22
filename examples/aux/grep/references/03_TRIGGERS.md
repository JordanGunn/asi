---
description: When this skill activates.
index:
  - Activation
  - Examples
---

# Triggers

## Activation

This skill activates when the user invokes `/grep` followed by a natural language prompt describing what they want to find.

## Examples

- `/grep find all usages of the deprecated API`
- `/grep where is authentication handled`
- `/grep error handling patterns in the codebase`
- `/grep TODO comments about performance`
- `/grep imports of the logging module`

The prompt is treated as intent. The agent compiles it into explicit search parameters.
