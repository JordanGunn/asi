---
description: Reference file for Instructions.
index:
  - Initialize
  - Critical: Execution Means Implementation
  - Policies
---

# Instructions

## Initialize

1. Read all reference files listed in `metadata.references` in order before taking action.
2. Determine the target plan using `./skill.sh status` or user specification.

## Critical: Execution Means Implementation

**This skill performs actual work.** When executing a task:

- Write real code, not pseudocode
- Create real files, not descriptions of files
- Make real changes, not plans for changes
- Produce real outputs, not placeholders

If a task's Work section says "Create a Python script", you must write and save that script. If it says "Update the configuration", you must edit that file. **Filling in Output with descriptions of what could be done is a failure mode.**

## Policies

### Always

1. **Actually perform** each step in the Work section.
2. Execute in order: sub-plans a → b → c, tasks i → ii → iii.
3. Each completed task must have:
   - **Output** with concrete, verifiable results
   - **Handoff** with explicit next step
4. Verify your work exists on disk before marking complete.

### Never

1. Never fill Output with descriptions instead of results.
2. Never mark a task complete without performing the Work.
3. Never work ahead on later sub-plans.
4. Never skip the wrap-up phase.
