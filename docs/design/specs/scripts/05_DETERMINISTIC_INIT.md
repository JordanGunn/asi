# Deterministic Init (Reference Loading)

Wrapper scripts must implement a deterministic `init` command that loads references in a fixed order.

Implementation rationale and benchmark-backed supporting evidence are documented in `docs/implementation/03_BENCHMARK_RATIONALE.md`.

## Requirements

- `init` concatenates references in ordinal order unless a router is present.
- If `00_ROUTER.md` exists, it is read first and determines which references load.
- `init` does not execute the skill or mutate state beyond loading references.
