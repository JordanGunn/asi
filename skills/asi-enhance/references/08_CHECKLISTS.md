# Checklists

## Reliability

- Explicit preconditions and failure handling are documented.
- Deterministic scripts exist for repetitive steps.
- Validation steps are present and runnable.

## Performance

- Heavy or repeated tasks are scripted.
- Large context files are moved to `references/`.
- Redundant instructions are removed from `SKILL.md`.

## Security

- No destructive scripts are run by default.
- External access (network, system changes) requires explicit approval.
- Sensitive data handling is documented and minimized.

## Structure

- `SKILL.md` has `name` and `description` frontmatter.
- `SKILL.md` body is concise and imperative.
- `assets/`, `scripts/`, `references/` exist (even if empty).
- Example or placeholder files are removed.
