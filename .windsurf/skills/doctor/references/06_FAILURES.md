---
description: What to do when things go wrong.
index:
  - Common Failure Cases
  - When to Abort
  - When to Continue
  - Surfacing Uncertainty
  - The Final Rule
---

# Failures

Handling uncertainty and errors in the doctor skill.

## Common Failure Cases

### No Matches Found

When `grep` returns no results:

1. Verify the search term is correct
2. Try broader patterns or different file types
3. Ask user for alternative terms
4. Document the negative result (absence of evidence is data)

### Multiple Viable Hypotheses

When confidence is spread across hypotheses:

1. Identify the key differentiator between them
2. Search for evidence that would falsify one
3. Present both to user for domain knowledge input
4. Do not force a single diagnosis

### Conflicting Evidence

When evidence supports contradictory conclusions:

1. Document both pieces of evidence explicitly
2. Consider whether the problem is multi-causal
3. Reduce confidence accordingly
4. Recommend targeted testing to resolve

### Stale Session

When resuming after context loss:

1. Run `./skill.sh status` to check session state
2. Review evidence files in `.doctor/evidence/`
3. Do not assume previous conversation context
4. Continue from recorded session state

## When to Abort

- User explicitly abandons investigation
- Problem is determined to be out of scope
- Required access is unavailable (logs, systems)
- Time constraints prevent proper investigation

## When to Continue

- Low confidence is normal early in investigation
- Negative search results are informative
- User frustration does not mean failure

## Surfacing Uncertainty

Always tell the user:

- Current confidence level
- What evidence would increase confidence
- What alternative explanations remain
- Whether more investigation is needed

## The Final Rule

> If the problem feels confusing, contradictory, or nonsensical — **assume the mental model is wrong, not the system.**
