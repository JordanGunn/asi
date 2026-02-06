# Legacy Migration Playbook

This playbook migrates legacy skills to ASI V2 implementation patterns.

For migration-era threat framing and residual-risk interpretation, see `docs/implementation/07_THREAT_MODEL_AND_NON_GOALS.md`.

## Migration Goals

- Move deterministic authority to CLI.
- Converge wrappers to canonical command surface.
- Consolidate reference files to canonical V2 set.
- Replace assets-based active schemas/templates with CLI emission.

## Phase 1: Inventory Current State

- Entry criteria:
  - Skill directory and wrapper scripts are available for inspection.
- Actions:
  - Identify wrapper commands in `scripts/skill.sh` and `scripts/skill.ps1`.
  - Enumerate reference files and routing behavior.
  - Audit assets for active schemas/templates.
  - Record current validation and failure/reporting behavior.
- Exit criteria:
  - Baseline inventory document exists with command surface, references, and asset audit.
- Rollback trigger:
  - Inventory materially incomplete (missing wrapper or reference surface data).
- Rollback verification:
  - Re-run inventory and confirm all baseline sections are populated.

## Phase 2: Normalize Wrapper Interface

- Entry criteria:
  - Baseline inventory is complete.
- Actions:
  - Add missing canonical commands: `help`, `init`, `validate`, `schema`, `run`.
  - Ensure command parity across shell and PowerShell wrappers.
  - Move business logic out of wrappers into CLI.
- Exit criteria:
  - Wrapper parity confirmed through command probe and help output diff.
- Rollback trigger:
  - Parity cannot be achieved without breaking existing invocation semantics.
- Rollback verification:
  - Previous wrapper behavior restored and command contract documented.

## Phase 3: Migrate Schema and Template Ownership

- Entry criteria:
  - Wrapper parity is established.
- Actions:
  - Replace assets-based active schemas/templates with CLI emission/apply.
  - Update `schema` command to proxy CLI output.
  - Keep legacy assets only for fixtures/examples, clearly flagged.
- Exit criteria:
  - `schema` output is CLI-sourced and active schema/template assets are absent.
- Rollback trigger:
  - CLI schema emission unavailable or incompatible with existing execution flow.
- Rollback verification:
  - Prior schema path restored temporarily with explicit legacy designation.

## Phase 4: Consolidate References

- Entry criteria:
  - CLI schema ownership migration is complete.
- Actions:
  - Refactor reference set to canonical V2 files.
  - Introduce `00_ROUTER.md` only when deterministic branching is required.
  - Verify `init` produces deterministic, single-stream onboarding output.
- Exit criteria:
  - Canonical reference set passes validation and `init` output is deterministic.
- Rollback trigger:
  - Consolidation removes required guidance or breaks route coverage.
- Rollback verification:
  - Prior reference set restored while gaps are documented and resolved.

## Phase 5: Validate and Cutover

- Entry criteria:
  - Reference consolidation complete and verified.
- Actions:
  - Run wrapper parity and read-only validation checks.
  - Confirm traceability from implementation choices to spec sources.
  - Confirm failure messages are explicit and deterministic.
  - Deprecate legacy paths and note compatibility impact.
- Exit criteria:
  - Blocking compliance checks pass and compatibility note is published.
- Rollback trigger:
  - Blocking checks fail or compatibility impact is unacceptable.
- Rollback verification:
  - Previous stable migration phase is restored and re-validated.

## Compatibility Statement Template

Use this template for migration cutovers:

```text
Compatibility statement:
- Previous interface preserved: <yes/no>
- Behavior changes introduced: <list>
- Legacy paths retained temporarily: <list or none>
- Removal/deprecation target version/date: <value>
- Required user/operator action: <value>
```

## Migration Completion Receipt Template

Use this template when migration is complete:

```text
Migration receipt:
- Skill: <name>
- Date: <YYYY-MM-DD>
- Completed phase: <1-5>
- Blocking checks: <pass/fail summary>
- Evidence artifacts:
  - <path>
  - <path>
- Remaining follow-ups: <none or list>
```
