---
description: Reference file for Procedure.
index:
  - Automated (Preferred)
  - Manual (Fallback)
  - Output Format
  - Interpreting Status
---

# Procedure

## Automated (Preferred)

Run the status script:

### macOS / Linux / WSL

```bash
.codex/skills/plan/plan-status/scripts/status.sh [phase-number]
```

### Windows (PowerShell)

```powershell
.codex\skills\plan\plan-status\scripts\status.ps1 [phase-number]
```

If no phase number is provided, defaults to the highest-numbered phase.

## Manual (Fallback)

If the script is unavailable:

1. Identify the target phase: `docs/planning/phase-<N>/`
2. Read `plan.md` frontmatter for overall status
3. For each sub-plan directory (a, b, c, ...):
   - Read `index.md` frontmatter for sub-plan status
   - For each task file (i.md, ii.md, ...):
     - Read frontmatter for task status
4. Summarize:
   - Total tasks, completed, in progress, pending
   - Progress percentage
   - Current active task (status: in_progress)

## Output Format

```
Phase <N> Status
────────────────
a/i.md    ✓ complete
a/ii.md   ✓ complete
a/iii.md  ● in_progress  ← active
b/i.md    ○ pending
b/ii.md   ○ pending

Progress: 2/5 tasks (40%)
```

## Interpreting Status

| Symbol | Status | Meaning |
|--------|--------|---------|
| ✓ | complete | Task finished with Output and Handoff |
| ● | in_progress | Currently being executed |
| ○ | pending | Not yet started |
