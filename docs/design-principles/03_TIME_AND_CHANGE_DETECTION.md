# 03. Use Time-Awareness and Change Detection to Prevent Rot

Ground reasoning in current reality, not historical truth.

- Use simple mechanisms to detect change and staleness (version control, timestamps, hashes, explicit invalidation signals).
- Prefer artifacts whose validity can be proven or invalidated.
- Use temporal signals to distinguish “this was true” from “this is still true”.

Conflicts between old artifacts and current state are signals to investigate, not prompts to patch blindly.

## Why this matters for ASI

ASI prioritizes auditable behavior over implied correctness. Time-awareness and change detection reduce reliance on stale implicit state and make “what was considered” more trustworthy (`docs/spec/rfc-001/.INDEX.md`, `docs/spec/rfc-003/.INDEX.md`).
