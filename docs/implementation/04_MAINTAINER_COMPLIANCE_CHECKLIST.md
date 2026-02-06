# Maintainer Compliance Checklist

Use this checklist when creating or reviewing ASI V2 skills.

For claim-level verification expectations, use `docs/implementation/06_CLAIMS_AND_EVIDENCE_MATRIX.md`.

Normative sources:

- `docs/design/specs/references/06_VALIDATION.md`
- `docs/design/specs/scripts/02_WRAPPER_INTERFACE.md`
- `docs/design/specs/scripts/03_CLI_BOUNDARY.md`
- `docs/design/specs/scripts/04_SCHEMAS_TEMPLATES.md`
- `docs/design/specs/scripts/05_DETERMINISTIC_INIT.md`

## Blocking Checks (`MUST`)

- [ ] `scripts/skill.sh` and `scripts/skill.ps1` both exist.
- [ ] Both wrappers expose `help`, `init`, `validate`, `schema`, `run`.
- [ ] Wrapper behavior delegates deterministic behavior to the agent-owned CLI.
- [ ] `validate` is read-only and safe to re-run.
- [ ] Canonical references exist: `01_SUMMARY.md`, `02_INTENT.md`, `03_POLICIES.md`, `04_PROCEDURE.md`.
- [ ] `00_ROUTER.md` exists only when lifecycle routing is required.
- [ ] `init` loads references deterministically (ordinal or router-selected).
- [ ] `schema` command proxies CLI schema emission.
- [ ] Active schemas/templates are not stored under skill assets.
- [ ] Routing/preconditions report effective scope.
- [ ] Failure outputs are explicit and actionable.
- [ ] Skill implementation choices map to one or more docs in `docs/design/specs/`.

## Advisory Checks (`SHOULD`)

- [ ] Reference files remain small and focused (short-length heuristic).
- [ ] Legacy asset usage is explicitly marked as legacy.
- [ ] Execution/reporting artifacts are easy to audit.
- [ ] Implementation doc updates include linked spec impact or explicit no-impact statement.

## Review Output Format

- Check ID: short stable identifier (example: `BC-03`).
- Result: `PASS` or `FAIL`.
- Reason: one-sentence failure reason when `FAIL`.
- Remediation path: file path(s) required to resolve failure.

## Minimum Evidence Package

A review is complete only when all of the following are attached:

- Wrapper `help` output from both `skill.sh` and `skill.ps1`.
- `init` output sample showing deterministic ordering/scope.
- `schema` output sample proving CLI emission.
- Reference tree listing for canonical files and router justification (if present).
- Validation/check output demonstrating read-only checks and pass/fail behavior.
