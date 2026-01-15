---
description: Canonical execution path for this skill.
index:
  - Commands
  - Categories
  - Typical Flows
---

# Procedure

CLI commands for the changelog skillset.

## Commands

```bash
./skill.sh help                    # Show help
./skill.sh validate                # Check runnable
./skill.sh locate                  # Find changelog path
./skill.sh init [--force]          # Create from template
./skill.sh verify [path]           # Check format
./skill.sh add <cat> "<entry>"     # Add to [Unreleased]
./skill.sh release <version>       # Cut release
./skill.sh suggest                 # Show commits since tag
./skill.sh clean                   # No-op (no generated files)
```

## Categories

- **Added** — New features
- **Changed** — Changes in existing functionality
- **Deprecated** — Soon-to-be removed features
- **Removed** — Now removed features
- **Fixed** — Bug fixes
- **Security** — Vulnerability fixes

## Typical Flows

### Add Entry

```bash
./skill.sh suggest                           # See recent commits
./skill.sh add Fixed "Resolved login issue (#123)"
./skill.sh verify                            # Confirm valid
```

### Cut Release

```bash
./skill.sh verify                            # Pre-release check
./skill.sh release 1.2.0                     # Cut release
./skill.sh verify                            # Post-release check
```

### Initialize

```bash
./skill.sh locate                            # Check if exists
./skill.sh init                              # Create from template
```
