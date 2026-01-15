# Keep a Changelog Format (Distilled)

Source: Keep a Changelog 1.1.0 (https://keepachangelog.com/en/1.1.0/)

## Principles

- Changelogs are for **humans**, not machines
- Every version should have an entry
- Group changes by type
- Versions should be linkable
- Latest version comes first
- Release date is shown for each version

## Required Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

[Unreleased]: https://github.com/user/repo/compare/vX.Y.Z...HEAD
[X.Y.Z]: https://github.com/user/repo/compare/vX.Y.W...vX.Y.Z
```

## Categories (Canonical Order)

| Category | Use For |
|----------|---------|
| **Added** | New features |
| **Changed** | Changes in existing functionality |
| **Deprecated** | Soon-to-be removed features |
| **Removed** | Now removed features |
| **Fixed** | Bug fixes |
| **Security** | Vulnerability fixes |

## Date Format

Always use: `YYYY-MM-DD` (ISO 8601)

Example: `2024-01-15`

## Version Format

Use Semantic Versioning: `MAJOR.MINOR.PATCH`

- Prefix with `v` in tags: `v1.2.3`
- No prefix in changelog: `[1.2.3]`

## [Unreleased] Section

- Always present at top
- Contains all unreleased changes
- Emptied when cutting a release
- Immediately recreated after release

## Link References

Place at bottom of file:

```markdown
[Unreleased]: https://github.com/user/repo/compare/v1.2.3...HEAD
[1.2.3]: https://github.com/user/repo/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/user/repo/releases/tag/v1.2.2
```

## Common Footguns

- Commit log dumps (not curated)
- Missing [Unreleased] section
- Inconsistent date formats
- Empty categories (remove if unused)
- Duplicate entries for same change
- Missing link references
