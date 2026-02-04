# Wrapper Interface (skill.sh / skill.ps1)

## Required Commands

Both `skill.sh` and `skill.ps1` must expose the same command surface.

- `help`
- `init`
- `validate`
- `schema`
- `run`

## Command Behavior

- `help` prints canonical usage for the wrapper and the underlying CLI.
- `init` deterministically loads references in the required order.
- `validate` runs read-only checks and returns non-zero on failure.
- `schema` emits the plan schema by proxying the CLI.
- `run` executes the skill via the CLI and supports `--stdin` plan mode.

## Execution Constraints

- Commands are safe to re-run.
- No command mutates the repo unless the CLI is explicitly performing execution.
- Wrapper scripts must be thin and stable, delegating behavior to the CLI.
