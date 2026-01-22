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
- Emit search results without the parameter block
- Use unbounded searches (must always have caps)
- Interpret results beyond surface-level evidence
- Make claims about code behavior based on grep hits alone
- Auto-widen scope without explicit user consent
