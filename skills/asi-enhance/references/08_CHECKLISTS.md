# Checklists

## Reliability

- Explicit preconditions and failure handling are documented.
- Deterministic scripts exist for repetitive steps.
- Validation steps are present and runnable.
- Review the target skill's `.asi/enhance/STATE.json`, `.asi/enhance/SCAN.md`, and `.asi/enhance/ENHANCEMENT_REPORT.md` before editing and mark which gating steps (plan approval, reruns) will be used.
- Confirm that `scripts/ensure_workplan_artifacts.py --definition plans/workplan.json --plan WORKPLAN.md --progress execution/phase_progress.json` runs cleanly and that `execution/next_task_context.json` describes the next phase/task before implementation. The guard script reruns the generator when the definition changes so downstream agents always see the latest metadata.
- Verify that your plan aligns with at least one target paradigm, one positive pattern, and avoids the listed anti-patterns in `references/09_PARADIGMS.md`.

## Performance

- Heavy or repeated tasks are scripted.
- Large context files are moved to `references/`.
- Redundant instructions are removed from `SKILL.md`.
- Route readers directly to the correct reference set to avoid re-deriving the same steps in each enhancement cycle.

## Security

- No destructive scripts are run by default.
- External access (network, system changes) requires explicit approval.
- Sensitive data handling is documented and minimized.
- Sensitive or cross-skill operations must be called out in `.asi/enhance/ENHANCEMENT_REPORT.md` and require plan approval or `asi-exec` hand-off before implementation.
- When using the `librarian` scripts for remote discovery or access, document the tool invocation, the `--root`/`--db` values, and the associated logs (`execution/index.log`, `execution/verify.log`, `execution/purge.log`) to keep the trace auditable.

## Structure

- `SKILL.md` has `name` and `description` frontmatter.
- `SKILL.md` body is concise and imperative.
- `assets/`, `scripts/`, `references/` exist (even if empty).
- Example or placeholder files are removed.
- Instructions explicitly reference the artifacts (`STATE.json`, `SCAN.md`, `ENHANCEMENT_REPORT.md`, `CHANGELOG_ENTRY.md`) and the gating flow (router → plan → approval).
- Ensure the instructions also mention `scripts/phase-helper.sh`, the `execution/phase_progress.json` tracker, and `execution/next_task_context.json` so reviewers always know where to look for structured context.
- Mention the `scripts/phase-helper.sh current-task --progress execution/phase_progress.json` invocation and the resultant structured message so the current/next task context can be previewed without advancing the tracker.
- Connect structural edits to the paradigms/patterns described in `references/09_PARADIGMS.md` so each change reinforces the desired mindset.
