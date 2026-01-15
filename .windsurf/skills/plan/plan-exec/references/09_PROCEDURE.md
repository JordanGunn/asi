---
description: Reference file for Procedure.
index:
  - Section Ownership
  - Step 1: Find Active Task
  - Step 2: Load and Validate
  - Step 3: Execute
  - Step 4: Advance
  - Step 5: Wrap-up
---

# Procedure

## Section Ownership

`plan-exec` populates **Output** and **Handoff** only.

Focus, Inputs, and Work come from `plan-create`. If these contain placeholders, halt and notify the user.

## Step 1: Find Active Task

```bash
./skill.sh status <N>
```

The first task with `status: pending` or `status: in_progress` is the active task.

## Step 2: Load and Validate

Read:
- Root: `.plan/<N>/plan.md`
- Sub-plan: `.plan/<N>/<letter>/index.md`
- Active: `.plan/<N>/<letter>/<roman>.md`

Verify Work section has actionable steps (not placeholders).

## Step 3: Execute

### Update Status

Set `status: in_progress` in the task frontmatter.

### Perform the Work

**This is the critical step.** For each item in Work:

1. Read the instruction
2. **Do it** — write code, create files, run commands
3. Verify the result exists on disk

### Record Output

Write concrete results:

```markdown
## Output

- Created `src/utils/parser.py` (47 lines)
- Updated `config.yaml` with new endpoint
- Ran tests: 12 passed, 0 failed
```

**Bad Output (failure mode):**

```markdown
## Output

Would create a parser module that handles...
```

### Write Handoff

Provide explicit next step for the following task.

### Update Status

Set `status: complete` in the task frontmatter.

## Step 4: Advance

Move to next task (i → ii → iii) or next sub-plan (a → b → c).

Repeat Steps 2-4 until all tasks complete.

## Step 5: Wrap-up

When all sub-plans complete:

1. Update `plan.md` frontmatter: `status: complete`
2. Check off success criteria with evidence
3. Append **Plan Summary** section
