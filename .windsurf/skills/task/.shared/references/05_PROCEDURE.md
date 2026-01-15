---
description: Canonical execution path for this skill.
index:
  - Commands
  - Typical Flow
  - Task Structure
  - Task File Format
---

# Procedure

CLI commands for the task skillset.

## Commands

```bash
./skill.sh help              # Show help
./skill.sh validate          # Check runnable
./skill.sh list              # List all tasks
./skill.sh list --status X   # Filter by status
./skill.sh create "title"    # Create new task
./skill.sh select <id>       # Select task as active
./skill.sh show              # Show active task
./skill.sh close             # Close active task
./skill.sh clean             # Remove closed tasks
```

## Typical Flow

1. `./skill.sh create "Task description"` — Create task
2. `./skill.sh select <id>` — Select for work
3. Do the work
4. `./skill.sh close` — Mark complete

## Task Structure

```text
.task/
├── <hash1>.md     # Task file
├── <hash2>.md     # Task file
└── active         # Points to current task
```

## Task File Format

```yaml
---
id: abc123
title: Task description
status: open
created_at: 2024-01-01T00:00:00Z
---

## Description

Task details here.
```
