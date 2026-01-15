---
description: Canonical execution path for this skill.
index:
  - Step 1: Run Lint
  - Step 2: Review Structure
  - Step 3: Review Clarity
  - Step 4: Document Findings
  - Step 5: Handoff
---

# Procedure

## Step 1: Run Lint

```bash
./skill.sh lint <target>
```

Record any findings.

## Step 2: Review Structure

Assess:
- Heading hierarchy (H1 → H2 → H3)
- Section balance (similar depth)
- Logical flow between sections

## Step 3: Review Clarity

For each section:
- Is the purpose clear?
- Is the language concise?
- Are there ambiguous statements?

## Step 4: Document Findings

Structure output as:

```markdown
## Review Findings

### Critical (must fix)
- Issue 1 with location

### Recommended (should fix)
- Issue 2 with location

### Suggestions (consider)
- Idea 1
```

## Step 5: Handoff

Present findings to user with specific recommendations.
