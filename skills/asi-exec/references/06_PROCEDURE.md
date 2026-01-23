# Procedure

## Prerequisites

1. Confirm `.asi/plan/` directory exists
2. Confirm `.asi/plan/PLAN.md` exists with `status: approved`
3. Confirm `.asi/plan/TODO.md` exists
4. Confirm `.asi/kickoff/SCAFFOLD.json` exists (for scaffolding tasks)
5. Create `.asi/exec/` directory if it does not exist
6. Run drift detection (`validate --check plan-drift`)
7. If drift detected, halt and report

---

## Step 1: Select Task

1. Parse `.asi/plan/TODO.md` task list
2. If `task_filter` provided, select that task
3. Otherwise, find first task with `status: pending`
4. If task has `status: in_progress`, resume that task
5. If no pending tasks, report completion

**Output:** Selected task ID and description

---

## Step 2: Verify Dependencies

1. Read task's `depends_on` field
2. For each dependency:
   - Verify dependency task has `status: done`
   - If not, halt and report blocked dependencies

**Output:** Dependencies satisfied (or halt)

---

## Step 3: Begin Execution

1. Update task status to `in_progress` in `.asi/plan/TODO.md`
2. Log checkpoint: "Starting task {task_id}"
3. Read `.asi/plan/PLAN.md` section referenced by task's `source_section`
4. If scaffolding task, read structure from `.asi/kickoff/SCAFFOLD.json`

**Output:** Task marked in progress

---

## Step 4: Execute Task

1. Implement the task per PLAN.md specification
2. For each file to create/modify:
   - Create/modify the file
   - Log checkpoint: "Created/modified {file_path}"
3. Track all artifacts created/modified
4. Verify implementation matches specification

**Output:** Implementation artifacts (with per-file checkpoints)

---

## Step 5: Complete Task

1. Verify task requirements are met
2. Update task status to `done` in `.asi/plan/TODO.md`
3. Log checkpoint: "Completed task {task_id}"
4. Produce execution receipt
5. Append receipt to `.asi/exec/RECEIPT.md`

**Output:** Task marked done, receipt appended to `.asi/exec/RECEIPT.md`

---

## Step 6: Report

1. Summarize what was executed
2. List artifacts created/modified
3. Report any issues or observations
4. Indicate next pending task (if any)

---

## Completion Criteria (per task)

- [ ] Task status updated to `done`
- [ ] All specified artifacts exist
- [ ] Execution receipt produced
- [ ] No errors or errors handled with consent
