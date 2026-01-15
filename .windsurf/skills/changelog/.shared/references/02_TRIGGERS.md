---
description: When to invoke or exit this skill.
index:
  - Invoke When
  - Do Not Invoke When
  - Exit Immediately If
  - Do Not Infer
---

# Triggers

When to activate or exit the changelog skillset.

## Invoke When

- User describes a change that should be documented
- User is preparing a release
- User asks about recent changes
- PR is merged and needs changelog entry
- User requests changelog verification

## Do Not Invoke When

- Change is trivial (typo, formatting)
- Change is internal-only (CI config, dev tooling)
- User explicitly declines changelog update

## Exit Immediately If

- Entry successfully added
- Release successfully cut
- User cancels the operation

## Do Not Infer

- Do not add entries without user confirmation
- Do not assume category without context
- Do not release without explicit version
