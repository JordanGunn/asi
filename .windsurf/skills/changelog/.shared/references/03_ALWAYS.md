---
description: Non-negotiable invariants for this skill.
index:
  - Format Rules
  - Duplicate Prevention
  - Git Integration
  - CLI Usage
---

# Always

Non-negotiable invariants for the changelog skillset.

## Format Rules

- Always use Keep a Changelog 1.1.0 format
- Always use ISO 8601 dates (YYYY-MM-DD)
- Always use canonical categories only
- Always keep [Unreleased] section at top

## Duplicate Prevention

- Always check for existing entries before adding
- Always match by PR/issue key (#123, ABC-123)
- Always match by exact entry text
- Always warn if duplicate detected

## Git Integration

- Always use `./skill.sh suggest` to see recent commits
- Always curate suggestions into human-readable entries
- Always include relevant PR/issue references

## CLI Usage

- Always use `./skill.sh verify` before releases
- Always use `./skill.sh add` for entries (not manual edit)
- Always use `./skill.sh release` for version cuts
