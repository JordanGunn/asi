# Scripts

These scripts enforce deterministic structure and lightweight formatting checks.

## What scripts do

- Verify required directories and files exist.
- Verify reference file naming/order (`NN_*.md`).
- Run a lightweight Markdown lint if available, or perform minimal checks.

## What scripts do not do

- Generate or rewrite specification content.
- Mutate files unless explicitly invoked with a `--fix` flag (where supported).
- Perform background maintenance or implicit actions.

## How to run

- Structure validation: `scripts/check_structure.sh` (see `scripts/check_structure.sh --help`)
- Markdown checks: `scripts/lint_markdown.sh` (see `scripts/lint_markdown.sh --help`)
