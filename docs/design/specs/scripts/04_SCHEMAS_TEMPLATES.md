# Schemas and Templates (CLI-Owned)

Schemas and templates are owned by the CLI. Skills do not store schemas or templates as assets in ASI V2.

## Requirements

- The CLI emits schemas via `<cli> <skill> --schema`.
- Wrapper scripts must proxy `schema` to the CLI.
- Templates used for artifacts are emitted or applied by the CLI.

## Legacy Assets

- Existing skills may temporarily retain assets-based schemas or templates, but they must be flagged as legacy.
- New skills must not use assets-based schemas or templates.
