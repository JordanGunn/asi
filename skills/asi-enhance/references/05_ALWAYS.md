# Always

- Always inventory the current skill state with `scan_skill.py`, then review the target skill's `.asi/enhance/STATE.json`, `INVENTORY.json`, `SCAN.md`, `ENHANCEMENT_REPORT.md`, and `CHANGELOG_ENTRY.md` before editing.
- Always keep a clear enhancement report in `.asi/enhance/ENHANCEMENT_REPORT.md`.
- Always validate that `SKILL.md` has a complete `name` and `description` frontmatter.
- Always document any new scripts, how to run them, and where they fit in the checklist.
- Always include validation or verification steps for changes, and note when plan approval is required before implementation.
- Always refresh `references/09_PARADIGMS.md` at the start of a cycle so the paradigms, patterns, anti-patterns, and supporting references stay top of mind.
- Always run `scripts/generate_plan.py --definition plans/phase_plan.json --output WORKPLAN.md --progress execution/phase_progress.json` and `scripts/phase-helper.sh ensure-plan ...` before editing so the phased plan, phase tracker, and `execution/next_task_context.json` remain deterministic.
- Always peek at the structured context before starting or resuming work with `scripts/phase-helper.sh current-task --progress execution/phase_progress.json --output execution/next_task_context.json`; downstream skills read the same JSON message to stay aligned with the current phase/task.
