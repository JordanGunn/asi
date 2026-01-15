---
description: Common failure cases and how to surface them.
index:
  - Missing files
  - Malformed YAML
  - Hash mismatch
  - Stale contract
---

# Failures

## Missing files

- Report which required file is missing.

## Malformed YAML

- Report YAML parsing errors; do not attempt repairs.

## Hash mismatch

- Report which expand bundle failed integrity validation.

## Stale contract

- Report contract age and recommend refresh.
