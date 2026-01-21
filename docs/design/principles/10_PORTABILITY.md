# Portability

Skills must be portable across common host environments without hidden installation or runtime assumptions.

## OS-native entrypoints (required)

- Use OS-native scripts as the top-level entrypoints within a skill.
- At minimum, provide both:
  - `*.sh` for POSIX shells
  - `*.ps1` for PowerShell
- Scripts should be thin wrappers that:
  - validate inputs and environment
  - invoke the implementation
  - emit deterministic receipts

## Runtime dependencies (required when non-native)

If the implementation depends on a language runtime that is not guaranteed to exist:

- Include the project/package files that define the runtime environment, for example:
  - `pyproject.toml` / lockfile
  - `package.json` / lockfile
  - `go.mod`
  - `Cargo.toml`
- Provide bootstrap scripts at the skill root (not in `scripts/`):
  - `bootstrap.sh`
  - `bootstrap.ps1`

## Bootstrap consent (hard rule)

- A skill must never install dependencies without explicit user permission.
- Validation should fail fast and report the missing dependency or environment.
- The agent must stop and request permission before any bootstrap action.

## Layout guidance

- Keep runtime wrappers in `scripts/` and bootstrap at the skill root.
- Prefer deterministic wrappers that are safe to re-run.
- Avoid hidden installs, implicit caches, or mutable global state.

