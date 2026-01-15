---
description: Reference file for Instructions.
index:
  - Initialize
  - Usage
  - Output
---

# Instructions

## Initialize

1. Read all reference files listed in `metadata.references` before taking action.

## Usage

Run the CLI to display plan status:

```bash
./skill.sh status [N]
```

If N is omitted, shows the latest plan.

## Output

The status command displays:

- Plan number and title
- Overall status
- Sub-plan progress (tasks complete / total)
- Individual task statuses
