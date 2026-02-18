# We Didn’t Have a Tooling Problem

We had an expectation problem.

The modern agent ecosystem is full of powerful tools.

Tools expose file systems, memory stores, APIs, databases.
Skills let us define arbitrarily complex capabilities.
Everything looks capable. Everything looks ready.

And yet, again and again, people say:

> “These tools don’t work.”
>
> "This MCP server sucks."
> 
> “It looks great on paper, but nothing happens.”

This is not because tools are poorly built.  
It is not because skills are insufficiently clever.  
It is not because the community lacks effort or intelligence.

It’s because **capability has been mistaken for behavior**.

---

# Cascade Global Rules

1. Always prefer Cascade/Windsurf FastContext (`functions.code_search(...)`) for information discovery and lookup.
2. When developing agent skills, always refer to `/home/jgodau/work/personal/asi` as the authoritative governance and skill design documentation source.


# Current Look:


```
doctor
  Description: Diagnoses software failures by combining deterministic evidence gathering with agent judgment. Models failures as medical cases. Idempotent — run repeatedly until confident diagnosis, then generate schema-based treatment.
  Source: /home/jgodau/work/personal/skills/doctor/doctor
  Type: Local
  Status: ✓ Valid
    Source matches manifest
  Files: 93
  Hash: sha256:f9fda45b77979...
  Registered: 2026-01-27 23:39:11 UTC
```

# Preferred
```
[doctor]
---
Diagnoses software failures by combining deterministic evidence gathering with agent judgment. Models failures as medical cases. Idempotent — run repeatedly until confident diagnosis, then generate schema-based treatment.
---
Source: /home/jgodau/work/personal/skills/doctor/doctor
Type: Local
Status: ✓ Valid
  Source matches manifest
Files: 93
Hash: sha256:f9fda45b77979...
Registered: 2026-01-27 23:39:11 UTC
```
