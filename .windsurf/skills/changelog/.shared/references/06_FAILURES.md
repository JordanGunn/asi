---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
---

# Failures

Handling errors in the changelog skillset.

## Common Failure Cases

### Changelog Not Found

When `./skill.sh locate` returns not found:

1. Run `./skill.sh init` to create
2. Customize the template as needed
3. Commit the new file

### Duplicate Entry Detected

When adding an entry that already exists:

1. CLI will warn and skip
2. Review existing entries
3. Update existing entry if needed

### Verification Failures

When `./skill.sh verify` finds issues:

1. Review reported issues
2. Fix manually or use CLI commands
3. Re-run verify to confirm

### Empty [Unreleased] on Release

When releasing with no unreleased entries:

1. CLI warns and refuses
2. Use `--force` if intentional
3. Consider if release is needed

## When to Abort

- User cancels the operation
- Verification fails critically
- Changelog is severely malformed

## When to Continue

- Minor format warnings
- Empty categories (will be cleaned)
- Missing link refs (can be added)
