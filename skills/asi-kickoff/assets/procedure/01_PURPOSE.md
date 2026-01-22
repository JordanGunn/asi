# Purpose

This document defines the **canonical kickoff procedure** for designing an ASI-compliant skill.

Its purpose is to allow an agent to:

* scaffold repository structure
* classify responsibility
* maximize deterministic surface area
* explicitly isolate agent reasoning
* design epistemic guardrails
* produce a reviewable implementation plan

This kickoff **does not authorize implementation**.
It exists to reduce ambiguity, not to fill it.

All decisions must comply with ASI specifications located at:

```
../asi/
```

These specifications are **normative**.

## Principle

> **Agents should reason only after reality has been mechanically reduced, validated, and time-scoped.**

This kickoff exists to enforce that principle — not to shortcut it.
