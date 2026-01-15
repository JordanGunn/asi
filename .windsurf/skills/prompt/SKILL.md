---
name: prompt
description: >
  Orchestrator skill for the `prompt` skillset. Separates intent formation from
  execution to protect humans from premature or misaligned action.
metadata:
  author: Jordan Godau
  version: 0.1.0
  skillset:
    name: prompt
    schema_version: 1
    skills:
      - prompt-forge
      - prompt-compile
      - prompt-exec
    shared:
      root: .shared
---

# INSTRUCTIONS

1. Refer to `.pipelines/.INDEX.md`.
