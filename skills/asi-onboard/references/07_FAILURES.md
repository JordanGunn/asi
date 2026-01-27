# Failures

## Missing tooling (jq)

Most scripts rely on `jq` for JSON handling.

Run:

```bash
scripts/bootstrap.sh --check
```

If `jq` is missing, install it and rerun `scripts/init.sh`.

## Session drift / noise

If NOTES.md has grown noisy or duplicated:

- Prefer editing NOTES.md to restore concision (human-maintained summary).
- If you must restart, delete `.asi/onboard/` and rerun `scripts/init.sh --topic "<topic>"`.

## User asks for planning or implementation

Stop onboarding immediately and route:

- Planning/design → `asi-plan`
- Execution → `asi-exec`

