# Procedure

## Step 1: Intake

- Confirm the target skill path and desired outcomes, noting whether the focus is reliability, performance, security, or another improvement.
- Decide whether the work will stay within the existing ASI structure or require converting a legacy skill, and keep that in mind while reading the router.

## Step 2: Initialize artifacts

- Run `scripts/init.sh --skill-path "<path>"` to ensure `.asi/enhance/STATE.json` exists and captures the initialization timestamp.
- Note any pre-existing contents in `.asi/enhance/CHANGELOG_ENTRY.md` and `.asi/enhance/ENHANCEMENT_REPORT.md` before overwriting them.

## Step 3: Inventory

- Run `python3 scripts/scan_skill.py --skill-path "<path>" --out-dir ".asi/enhance"`.
- Review the target skill's `.asi/enhance/SCAN.md`, `.asi/enhance/STATE.json`, and `.asi/enhance/INVENTORY.json` for missing directories, TODOs, or issues and capture those findings in the report.
- Read `references/09_PARADIGMS.md` before selecting a route so you can record the target paradigms, helpful patterns, and anti-patterns that will guide the plan.
- Run `scripts/ensure_workplan_artifacts.py --definition plans/workplan.json --plan WORKPLAN.md --progress execution/phase_progress.json` and confirm that `execution/phase_progress.json` plus `execution/next_task_context.json` exist before drafting tasks—they are the deterministic artifacts this skill now emits; the guard script keeps the metadata in sync and regenerates the markdown whenever the definition changes.

## Step 4: Decide route

- Use `references/00_ROUTER.md` to choose the appropriate route (already-ASI, convert-to-ASI, or enhance-only).
- Record the selected route inside `.asi/enhance/ENHANCEMENT_REPORT.md` so downstream reviewers understand which reference set was used.

## Step 5: Draft enhancement report

- Populate `.asi/enhance/ENHANCEMENT_REPORT.md` with the scan timestamp, gaps, proposed changes, acceptance criteria, and notes about which reliability/performance/security checklists from `references/08_CHECKLISTS.md` apply.
- Add a short entry to `.asi/enhance/CHANGELOG_ENTRY.md` summarizing the enhancement intent.
- Reference `references/05_ALWAYS.md` to remind yourself about the artifacts you must review before claiming the plan is ready.

## Step 6: Build the enhancement plan

- Break the work into discrete structural, content, script, and reference tasks, flagging any item that touches user-facing behavior as high-risk.
- Identify the gating steps (e.g., plan approval, additional scans, logging requirements) and make sure the report includes them.
- Note in the plan whether the change touches other skills or shared infrastructure so reviewers can evaluate cross-skill impact.

## Step 7: Implementation (gated)

- Do not modify the target skill until this plan is approved.  If implementation is requested, either pass the work to `asi-exec` or explicitly get user approval before starting edits.
- Document any destructive actions (file deletions, database purges, required approvals) inside the enhancement report and link to the relevant `references/04_NEVER.md` guidance.

## Step 8: Validate and close

- After applying approved changes, rerun `python3 scripts/scan_skill.py --skill-path "<path>" --out-dir ".asi/enhance"` and compare the new `SCAN.md`/`STATE.json` to the pre-change baseline.
- Update `.asi/enhance/ENHANCEMENT_REPORT.md` with validation notes, mark off the checklist items you executed, and confirm that the changelog reflects the completed work.
- If outstanding decisions remain, list them at the bottom of the report so future agents know what still needs approval.
