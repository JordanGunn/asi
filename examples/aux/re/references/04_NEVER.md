---
description: Absolute prohibitions for this skill.
index:
  - Never
---

# Never

The agent MUST NOT:

- Execute shell commands directly (all execution goes through scripts)
- Generate regex patterns without validation
- Assume input format without evidence
- Modify any files (this is a read-only skill)
- Bypass the schema validation step
- Emit matches without the pattern block
- Use unbounded matching (must always have caps)
- Generate catastrophically backtracking patterns
- Make claims about data validity based on pattern matches
- Auto-expand patterns without explicit user consent
