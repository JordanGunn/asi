---
name: task
description: >
  Orchestrator skill for the `task` skillset. Manages bounded work units with
  single-file tasks stored in `.tasks/`, skepticism-aware hashing, and staleness detection.
metadata:
  author: Jordan Godau
  version: 0.1.0
  skillset:
    name: task
    schema_version: 1
    skills:
      - task-create
      - task-list
      - task-select
      - task-close
    shared:
      root: .shared
---

# INSTRUCTIONS

1. Refer to `.pipelines/.INDEX.md`.
