# ASI Enhance

`asi-enhance` now produces deterministic, phased plans much like the workplan skill did for developer. The new generator (`scripts/generate_plan.py`) reads `plans/phase_plan.json`, renders `WORKPLAN.md`, and writes `execution/phase_progress.json` plus the structured context file `execution/next_task_context.json`. The helper script (`scripts/phase-helper.sh`) invokes the generator before execution, returns the next task context after each completion, and can emit the current task context on demand so downstream skills receive the right context without re-reading the entire plan.

## Workflow

1. Update `plans/phase_plan.json` with the desired phases, tasks, commands, and verification entries for this enhancement.
2. Run `python3 scripts/generate_plan.py --definition plans/phase_plan.json --output WORKPLAN.md --progress execution/phase_progress.json` to create the plan and tracker.
3. Before running `execute-plan.sh`, call `./scripts/phase-helper.sh ensure-plan --definition plans/phase_plan.json --plan WORKPLAN.md --progress execution/phase_progress.json` (the master workflow automatically includes this invocation).
4. After each completed task, run `./scripts/phase-helper.sh next-task --plan WORKPLAN.md --progress execution/phase_progress.json --task <id> --output execution/next_task_context.json` to capture the structured context for the next task.
5. When you need to preview the currently active or next task without advancing the tracker, run `./scripts/phase-helper.sh current-task --progress execution/phase_progress.json --output execution/next_task_context.json`; it emits the same structured JSON message that downstream agents read to minimize context rot.

## Artifacts

- `plans/phase_plan.json` – defines each phase/task plus commands/verification/metadata.
- `WORKPLAN.md` – generated plan consumed by the developer skill, containing the new metadata block referencing `asi-enhance`.
- `execution/phase_progress.json` – records the current phase/task status.
- `execution/next_task_context.json` – structured JSON with the next task’s summary, commands, verification, and phase context.

## Command checklist

- `./scripts/generate_plan.py --definition plans/phase_plan.json --output WORKPLAN.md --progress execution/phase_progress.json`
- `./scripts/phase-helper.sh ensure-plan --definition plans/phase_plan.json --plan WORKPLAN.md --progress execution/phase_progress.json`
- `./scripts/phase-helper.sh next-task --plan WORKPLAN.md --progress execution/phase_progress.json --task <id>`
- `./scripts/phase-helper.sh current-task --progress execution/phase_progress.json`

Document your decisions in `references/QUESTIONS.md`, follow the guard scripts from `references/command-checklist.md`, and keep the ASI paradigms from `references/09_PARADIGMS.md` in mind.
