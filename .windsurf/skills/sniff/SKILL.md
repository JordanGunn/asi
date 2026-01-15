---
name: sniff
description: >
  Detects recognized code smells using deterministic heuristics and maintains a
  lightweight, self-validating index of findings under `.sniff/`.
metadata:
  author: Jordan Godau
  version: 0.1.0
  skillset:
    name: sniff
    schema_version: 1
    skills:
      - sniff-bloaters
      - sniff-couplers
      - sniff-abusers
      - sniff-preventers
      - sniff-locate
    shared:
      root: .shared
    pipelines:
      default:
        - sniff-bloaters
        - sniff-couplers
        - sniff-abusers
        - sniff-preventers
        - sniff-locate
      allowed:
        - [sniff-bloaters]
        - [sniff-couplers]
        - [sniff-abusers]
        - [sniff-preventers]
        - [sniff-locate]
        - [sniff-bloaters, sniff-locate]
        - [sniff-couplers, sniff-locate]
        - [sniff-abusers, sniff-locate]
        - [sniff-preventers, sniff-locate]
        - [sniff-bloaters, sniff-couplers, sniff-abusers, sniff-preventers, sniff-locate]
  keywords:
    - smell
    - smells
    - code-quality
    - refactor
    - locator
---

# INSTRUCTIONS

1. Refer to `.pipelines/.INDEX.md`.
