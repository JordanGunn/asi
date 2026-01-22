---
description: Mandatory behaviors for this skill.
index:
  - Always
---

# Always

The agent MUST:

- Compile intent into a schema-valid plan before execution
- Include the parameter block in all output
- Declare explicit root, patterns, excludes, type, and caps
- Use stable sorting for all lists
- Report empty results with full scope context
- Hash the intent for reproducibility
- Respect budget caps (max_results, max_depth)
- Use the scripts for all execution (never raw shell)
- Present file lists, not interpretations
- Stop if schema validation fails
