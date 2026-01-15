# Bootstrap policy

**Placement:** a user-initiated bootstrap script lives at the skill root, beside `README.md`.

- `bootstrap.sh`
- `bootstrap.ps1`

**Validate must be read-only:** it fails fast if dependencies or a venv are missing.

**Rationale:**

- avoids hidden installs
- makes consent explicit
- keeps environment changes localized to the skill

**Example flow:**

1. Run `validate`.
2. Validation reports missing venv/dependencies.
3. Agent stops and asks permission.
4. User runs `bootstrap` manually.
5. Agent re-runs `validate` and proceeds.

**Hard rule:** the agent must stop and request permission before any bootstrap is run.
