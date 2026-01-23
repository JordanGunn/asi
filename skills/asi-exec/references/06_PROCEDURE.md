# Procedure

Execute tasks using the deterministic-first flow below.

---

## Execution Model

```text
Script (init.sh)           → Validates prereqs, parses plan, creates state
Script (select-task.sh)    → Deterministically selects next task, validates deps
Script (update-status.sh)  → Updates TODO.md status (agent never edits TODO)
Agent (execute)            → Implements task, produces JSON output
Script (append-receipt.sh) → Appends receipt to RECEIPT.md
Script (checkpoint.sh)     → Validates state, checks drift
```

The agent implements tasks but **never edits TODO.md directly**. Scripts handle all status updates.

---

## Step 0: Deterministic Preamble (REQUIRED)

**Before any agent reasoning**, run the initialization script:

```bash
scripts/init.sh
```

This:

- Validates prerequisites (PLAN.md approved, TODO.md exists)
- Parses plan artifacts into `.asi/exec/PLAN_PARSED.json`
- Creates STATE.json to track execution progress
- Creates RECEIPT.md for execution logs

**Do not skip this step. Do not have the agent parse TODO.md directly.**

---

## Step 1: Select Task (Deterministic)

Run the task selection script:

```bash
scripts/select-task.sh [--task T001]
```

This:

- Finds next task (in_progress > pending)
- Validates dependencies are satisfied
- Updates STATE.json with current task
- Emits task details as JSON

If blocked, the script reports which dependencies are unsatisfied.

---

## Step 2: Mark In Progress (Deterministic)

Before executing, mark the task in progress:

```bash
scripts/update-status.sh --task T001 --status in_progress
```

This updates TODO.md deterministically. The agent does not edit TODO.md.

---

## Step 3: Execute Task (Agent)

The agent:

1. Reads task details from `select-task.sh` output
2. Reads relevant PLAN.md section (from `source_section`)
3. Implements the task per specification
4. Produces JSON output conforming to `task_output_v1.schema.json`
5. Saves output to `.asi/exec/task_T001_output.json`

```bash
# Validate with checkpoint
scripts/checkpoint.sh --check task-ready
```

---

## Step 4: Mark Done (Deterministic)

After successful execution:

```bash
scripts/update-status.sh --task T001 --status done
```

---

## Step 5: Append Receipt (Deterministic)

Agent produces receipt JSON conforming to `exec_receipt_v1.schema.json`:

```bash
scripts/append-receipt.sh --input .asi/exec/task_T001_receipt.json
```

This appends the formatted receipt to RECEIPT.md.

---

## Step 6: Verify and Continue

```bash
scripts/checkpoint.sh --check task-complete
scripts/checkpoint.sh --check drift
```

If more tasks remain:

```bash
scripts/select-task.sh
# Repeat from Step 2
```

If all tasks done:

```bash
scripts/checkpoint.sh --check all-done
```

---

## Completion Criteria (per task)

- [ ] `scripts/checkpoint.sh --check task-complete` passes
- [ ] Task status is `done` in TODO.md
- [ ] Task output JSON exists (`.asi/exec/task_T001_output.json`)
- [ ] Receipt appended to RECEIPT.md
- [ ] No drift detected

---

## Completion Criteria (all tasks)

- [ ] `scripts/checkpoint.sh --check all-done` passes
- [ ] All tasks in TODO.md have `status: done`
- [ ] RECEIPT.md contains entry for each task
- [ ] No errors or errors handled with consent

---

## Why This Flow?

1. **Scripts parse plan** — Agent reasons over structured JSON, not raw markdown
2. **Task selection is deterministic** — Dependencies validated before execution
3. **Status updates are scripted** — Agent cannot corrupt TODO.md format
4. **Receipts are appended by script** — Consistent formatting, audit trail
5. **Checkpoints gate progression** — Drift and state validated at each step
6. **Execution is single-task** — One task at a time, fully complete or defer
