---
description: "Skill design kickoff for papi-research"
timestamp: "2026-01-26T19:02:18Z"
status: draft
skill_name: "papi-research"
skill_purpose: "Sequentially execute preprocessing research items (R1, R2, ...) and update R*.md artifacts with findings and links (depends_on, related_design)."
step: 2
---

# Kickoff: papi-research

## Purpose

### What this skill does

Finds the first R*.md with status: todo, performs the described research, then updates that same file with findings and links.

### What problem it solves

Keeps GeoConnections preprocessing research sequential, auditable, and consistently documented across R1, R2, etc.

### What this skill does NOT do

- Does not implement production features; research only.
- Does not skip items or reorder them without explicit instruction.
- Does not invent findings; must cite sources/artifacts.

### Governing ASI principles

- Deterministic-first: choose next item by status + numeric order.
- Auditability: update R*.md with structured outputs and artifact links.
- No implementation: creates research artifacts, not product code.

---
## Deterministic Surface

### Mechanisms

<!-- AGENT: Fill this table -->

| Mechanism | Inputs | Outputs | Failure Conditions | Idempotent |
| --------- | ------ | ------- | ------------------ | ---------- |
|           |        |         |                    |            |

### Observable Signals

<!-- AGENT: Fill this section -->

---

## Judgment Remainder

### Items requiring judgment

<!-- AGENT: Fill this table -->

| Decision | Why Not Deterministic | Category | Blocking Reason |
| -------- | --------------------- | -------- | --------------- |
|          |                       |          |                 |

### Disallowed shortcuts

<!-- AGENT: Fill this section -->

---

## Schema Designs

### Intent Schema

<!-- AGENT: Fill this section -->

```json
{
  "$comment": "Shape only - no logic"
}
```

### Execution Plan Schema

<!-- AGENT: Fill this section -->

```json
{
  "$comment": "Shape only - no logic"
}
```

### Result Schema

<!-- AGENT: Fill this section -->

```json
{
  "$comment": "Shape only - no logic"
}
```

---

## Open Questions

<!-- AGENT: Capture only - do not answer -->

- [ ] 

