# Contracts

## Purpose Contract

`asi-onboard` exists to establish shared context about:

- repository entrypoints
- relevant docs and specs
- constraints and invariants the agent must follow

It does **not** design a new skill, produce a plan, or implement anything.

## Output Contract

The skill must produce/maintain:

- `.asi/onboard/NOTES.md` — a scoped context digest and working notes
- `.asi/onboard/SOURCES.md` — a list of sources consulted and why they matter
- `.asi/onboard/STATE.json` — idempotent lifecycle state

## Judgment Contract

The primary judgment this skill performs:

- selecting what to read next (given a user goal)
- extracting constraints and invariants
- maintaining a concise, durable context digest

Judgment must remain auditable via `reasoning_trace` in step outputs.

