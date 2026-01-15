---
description: Canonical execution path for this skill.
index:
  - Commands
  - Typical Flow
  - Plan Structure
---

# Procedure

CLI commands for the plan skillset.

## Commands

```bash
./skill.sh help              # Show help
./skill.sh validate          # Check runnable
./skill.sh list              # List all plans
./skill.sh status [N]        # Show plan status
./skill.sh next              # Get next plan number
./skill.sh init [N]          # Create plan skeleton
./skill.sh surface           # Scan for relevant files
./skill.sh clean <N>         # Remove plan N
./skill.sh clean --all       # Remove all plans
```

## Typical Flow

1. `./skill.sh init --title "Description"`
2. Edit `.plan/<N>/plan.md` with objective and criteria
3. Create sub-plans and tasks
4. Execute with plan-exec member skill
5. Review with plan-review member skill
6. `./skill.sh clean <N>` when complete

## Plan Structure

```
.plan/<N>/
├── plan.md           # Root plan
├── a/
│   ├── index.md      # Sub-plan A index
│   ├── i.md          # Task 1
│   └── ii.md         # Task 2
└── b/
    └── ...
```
