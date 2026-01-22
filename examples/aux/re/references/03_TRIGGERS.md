---
description: When this skill activates.
index:
  - Activation
  - Examples
---

# Triggers

## Activation

This skill activates when the user invokes `/re` followed by a natural language prompt describing what pattern they want to match or extract.

## Examples

- `/re extract all email addresses from this text`
- `/re find phone numbers in US format`
- `/re match all URLs in the document`
- `/re extract version numbers like v1.2.3`
- `/re find all IP addresses`
- `/re match dates in ISO format`

The prompt is treated as intent. The agent compiles it into an explicit regex pattern.
