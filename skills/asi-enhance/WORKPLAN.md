# WORKPLAN — asi-enhance skill

## Plan Metadata
Approval pattern: ^Approved:[[:space:]]+yes$
Required sections: Intent,Goals,Non-Goals,Scope,Constraints,Plan,Commands,Validation,Approval
Validation policy: explicit commands (guard scripts + scans)
Plan Source: asi-enhance
Plan Definition: plans/workplan.json
Phase progress file: execution/phase_progress.json

## Intent
Formalize the new asi-enhance workflow with phased planning and structured context for each enhancement task.

## Goals
- Document the new generator/TRACKER flow so authors know how to run it.
- Produce phased plans plus a phase tracker for enhancement tasks.
- Ensure the helper exposes the next task context for the developer skill.

## Non-Goals
- Execute commands without a plan approval.
- Replace external scripts such as workplan or developer.

## Scope
- Generate WORKPLAN.md from this definition.
- Emit execution/phase_progress.json and execution/next_task_context.json.
- Document the helper script that developers call after each completed task.

## Constraints
- Plans must include the required metadata block (Intent → Approval).
- Phase tracker must remain under execution/.
- Helper output must remain deterministic and auditable.

## Plan
### Phase 1 — Document the pipeline
Describe how asi-enhance now uses the generator/helper/progress tracker before enhancing a skill.
- [ ] T001: Clarify the new README and SKILL guidance to mention the phased plan definition and tracker.
  Update README.md, SKILL.md, and references to describe the generator, the
  helper, and the synchronized context files.
  Commands:
  - rg -n "workplan.json" README.md SKILL.md references/*.md
  Verification:
  - python3 scripts/ensure_workplan_artifacts.py --definition plans/workplan.json --plan WORKPLAN.md --progress execution/phase_progress.json

### Phase 2 — Implement the generator/tracker
Add scripts that render WORKPLAN.md from the definition and update the progress file.
- [ ] T002: Create scripts/generate_plan.py and scripts/update_phase_progress.py plus the phase definition.
  Ensure they stay deterministic, include metadata field references, and output
  `execution/next_task_context.json` when returning the next task.
  Commands:
  - python3 scripts/ensure_workplan_artifacts.py --definition plans/workplan.json --plan WORKPLAN.md --progress execution/phase_progress.json
  Verification:
  - cat execution/phase_progress.json

### Phase 3 — Helper integration
Expose scripts/phase-helper.sh so execute-plan runs workplan-like next-task queries.
- [ ] T003: Add scripts/phase-helper.sh and update documentation so the helper runs before/after tasks.
  The helper should regenerate the plan if needed and emit the next task context
  after updates.
  Commands:
  - ./scripts/phase-helper.sh ensure-plan --plan ./WORKPLAN.md --progress execution/phase_progress.json
  Verification:
  - ./scripts/phase-helper.sh next-task --plan ./WORKPLAN.md --progress execution/phase_progress.json --task T001 --output execution/next_task_context.json

## Commands
- python3 scripts/ensure_workplan_artifacts.py --definition plans/workplan.json --plan WORKPLAN.md --progress execution/phase_progress.json
- ./scripts/phase-helper.sh ensure-plan --definition plans/workplan.json --plan ./WORKPLAN.md --progress execution/phase_progress.json

## Validation
- ./scripts/validate-plan.sh --plan ./WORKPLAN.md --required "Intent,Goals,Non-Goals,Scope,Constraints,Plan,Commands,Validation,Approval" --approval-pattern "^Approved:[[:space:]]+yes$"
- ./scripts/check-workspace.sh --root . --fail-on-dirty

## Approval
Approved: yes
Approved by: bsmith
Approved on: 2026-01-28
