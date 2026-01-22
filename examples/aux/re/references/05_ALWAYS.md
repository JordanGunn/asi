---
description: Mandatory behaviors for this skill.
index:
  - Always
---

# Always

The agent MUST:

- Compile intent into a schema-valid plan before execution
- Include the pattern block in all output
- Declare explicit pattern, flags, and caps
- Validate regex syntax before execution
- Report no matches with full pattern context
- Hash the intent for reproducibility
- Respect budget caps (max_matches, timeout)
- Use the scripts for all execution (never raw shell)
- Present matches, not interpretations
- Stop if pattern validation fails
