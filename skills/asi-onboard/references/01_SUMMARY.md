# Summary

`asi-onboard` builds disk-backed context for working in this repository.

It is designed for **idempotent, resumable** doc exploration and context capture:

- Creates a scoped context digest in `.asi/onboard/NOTES.md`
- Tracks sources consulted in `.asi/onboard/SOURCES.md`
- Tracks lifecycle state in `.asi/onboard/STATE.json`

This skill is intentionally **not** part of the planning/execution gate:

- Not a kickoff skill (that is `asi-kickoff`, or the kickoff phase within `asi-plan`)
- Not a planning skill (that is `asi-plan`)
- Not an execution skill (that is `asi-exec`)

Primary outputs:

- `.asi/onboard/NOTES.md`
- `.asi/onboard/SOURCES.md`

