---
name: plan
description: >
  Orchestrator skill for the `plan` skillset. Manages bounded work units with
  structured plans stored in `.plan/`.
metadata:
  author: Jordan Godau
  version: 0.1.0
  skillset:
    name: plan
    schema_version: 1
    skills:
      - plan-create
      - plan-exec
      - plan-status
      - plan-review
    shared:
      root: .shared
---

# INSTRUCTIONS

1. Refer to `.pipelines/.INDEX.md`.
