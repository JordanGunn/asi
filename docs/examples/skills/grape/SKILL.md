---
name: grape
license: MIT
description: >
  AI-enabled, deterministic codebase search. Converts vague intent into explicit,
  auditable grep parameters and executes a stable surface scan over disk.
metadata:
  author: Jordan Godau
  version: 0.4.4
  references:
    - 00_ROUTER.md
    - 01_SUMMARY.md
    - 02_TRIGGERS.md
    - 03_NEVER.md
    - 04_ALWAYS.md
    - 05_PROCEDURE.md
    - 06_FAILURES.md
    - 07_COMPILER_CONTRACT.md
  scripts:
    - scripts/scan.sh
    - scripts/plan.sh
    - scripts/grep.sh
    - scripts/scan.ps1
    - scripts/plan.ps1
    - scripts/grep.ps1
    - bootstrap.sh
    - bootstrap.ps1
  assets:
    - assets/schemas/grape_intent_v1.schema.json
    - assets/schemas/grape_compiled_plan_v1.schema.json
    - assets/schemas/grape_surface_plan_v1.schema.json
    - assets/templates/grape_intent_v1.template.json
    - assets/templates/grape_compiled_plan_v1.template.json
    - assets/templates/grape_surface_plan_v1.template.json
    - assets/examples/grape_compiled_plan_v1.example.json
    - assets/examples/grape_surface_plan_v1.example.json
  artifacts: []
  keywords:
    - grep
    - search
    - discovery
    - surface
    - ripgrep
---

# INSTRUCTIONS

1. Refer to `metadata.references`.
