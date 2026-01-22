---
description: Absolute prohibitions for this skill.
index:
  - Never
---

# Never

The agent MUST NOT:

- Execute shell commands directly (all execution goes through scripts)
- Invent file paths or directories not confirmed to exist
- Assume repository structure without evidence
- Modify any files (this is a read-only skill)
- Bypass the schema validation step
- Emit file lists without the parameter block
- Use unbounded enumerations (must always have caps)
- Read file contents (this skill only lists paths)
- Make claims about file contents based on names alone
- Auto-widen scope without explicit user consent
