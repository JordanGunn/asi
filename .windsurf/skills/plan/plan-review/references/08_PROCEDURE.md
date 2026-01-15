---
description: Reference file for Procedure.
index:
  - Step 1: Load Plan
  - Step 2: Review Each Task
  - Step 3: Verify Success Criteria
  - Step 4: Produce Assessment
---

# Procedure

## Step 1: Load Plan

```bash
./skill.sh status <N>
```

Verify all sub-plans show complete status.

## Step 2: Review Each Task

For each task file, verify:

- **Output** contains concrete results (not placeholders)
- **Handoff** provides clear next-step guidance
- Work items were actually performed (check artifacts)

## Step 3: Verify Success Criteria

Read the root `plan.md` success criteria.

For each criterion:
- Check if evidence exists in task outputs
- Mark as met or unmet with brief justification

## Step 4: Produce Assessment

Append a **Review** section to `plan.md`:

```markdown
## Review

**Date**: YYYY-MM-DD
**Reviewer**: Agent

### Criteria Status

- [x] Criterion 1 — met (see a/ii.md Output)
- [ ] Criterion 2 — unmet (no evidence found)

### Strengths

- Item 1
- Item 2

### Gaps

- Item 1
- Item 2

### Recommendation

Brief recommendation for follow-up if needed.
```
