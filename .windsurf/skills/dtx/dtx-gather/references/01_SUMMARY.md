---
description: What this skill is and is not.
index:
  - What it does
  - What it is not
---

# Summary

`dtx-gather` performs deterministic evidence gathering (glob selection + ripgrep matches) and records results under `.dtx/EXPANDS/<EXP-ID>/`.

## What it does

- Selects files deterministically via user-provided globs
- Searches deterministically via user-provided ripgrep patterns
- Writes a stable artifact bundle (`files.txt`, `matches.txt`, `meta.yml`)

## What it is not

- Not a semantic search system
- Not a reasoning engine (it only gathers and records evidence)
