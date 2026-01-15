---
description: What this skill is and is not.
index:
  - What It Does
  - What Problems It Solves
  - What It Is Not
  - Key Invariant
  - Artifact Location
---

# Summary

The **changelog** skillset manages Keep a Changelog format files with deterministic operations and chrono-aware guardrails.

## What It Does

- Initializes changelogs from template (changelog-init)
- Adds entries with duplicate detection (changelog-update)
- Cuts releases with link reference updates (changelog-release)
- Verifies format compliance (changelog-verify)

## What Problems It Solves

- Prevents duplicate changelog entries
- Enforces Keep a Changelog 1.1.0 format
- Automates release section transformation
- Provides git-based entry suggestions

## What It Is Not

- Not a commit log dump
- Not for arbitrary markdown editing
- Not a replacement for human curation

## Key Invariant

**Curated, not generated.** The CLI provides structure and guardrails; the agent provides human-quality wording. Never dump commit logs verbatim.

## Artifact Location

Changelog at repo root: `CHANGELOG.md` (or `docs/CHANGELOG.md`)
