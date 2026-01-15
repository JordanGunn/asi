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

The **task** skillset manages lightweight task tracking with content-addressed storage.

## What It Does

- Creates tasks with frontmatter metadata (task-create)
- Lists tasks by status (task-list)
- Selects active task for work (task-select)
- Closes completed tasks (task-close)

## What Problems It Solves

- Tracks work items without heavyweight tooling
- Provides content-addressed storage (hash-based IDs)
- Enables simple task lifecycle management
- Creates queryable task artifacts

## What It Is Not

- Not a project management system
- Not for complex multi-step work (use plan skillset)
- Not a calendar or scheduler

## Key Invariant

**One active task.** Only one task can be selected at a time. Complete or deselect before switching.

## Artifact Location

All artifacts stored in `.task/`:

- `<hash>.md` — Individual task files
- `active` — Symlink or file pointing to current task
