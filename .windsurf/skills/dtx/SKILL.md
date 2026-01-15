---
name: dtx
license: MIT
description: >
  Orchestrator skill for the `dtx` skillset. Manages an agent's working context
  via explicit, auditable `.dtx/` artifacts.
metadata:
  author: Jordan Godau
  version: 0.1.0
  skillset:
    name: dtx
    schema_version: 1
    skills:
      - dtx-validate
      - dtx-state
      - dtx-gather
      - dtx-forget
    shared:
      root: .shared
---

# INSTRUCTIONS

1. Refer to `.pipelines/.INDEX.md`.
