---
description: "Skill design kickoff for asi-plan"
timestamp: "2026-01-22T18:45:00Z"
status: approved
skill_name: "asi-plan"
skill_purpose: "Decompose an approved KICKOFF.md into detailed PLAN.md and TODO.md artifacts"
---

# Kickoff: asi-plan

## Purpose

### What this skill does

`asi-plan` consumes an **approved** `KICKOFF.md` artifact and decomposes it into:

1. **PLAN.md** — Detailed implementation approach with:
   - Scripts to create/implement
   - Assets to produce
   - Validation mechanisms
   - Boundary definitions
   - Non-goals
   - Risk assessment
   - Lifecycle declaration

2. **TODO.md** — Ordered task list for execution tracking with:
   - Task descriptions
   - Dependencies
   - Status markers (`pending` | `in_progress` | `done`)

It transforms high-level design decisions into actionable, sequenced work items **without performing implementation**.

### What problem it solves

- Prevents jumping from kickoff directly to code
- Forces explicit task decomposition before execution
- Creates auditable trail of planned work
- Enables human review of detailed approach before commitment
- Separates "what to build" (PLAN.md) from "what's left" (TODO.md)

### What this skill does NOT do

- Does not implement code or scripts
- Does not execute tasks from TODO.md (that is `asi-exec`)
- Does not modify or regenerate KICKOFF.md
- Does not proceed without approved KICKOFF.md
- Does not auto-approve its own artifacts

### Governing ASI principles

- **Determinism-before-reasoning**: Validate KICKOFF.md status deterministically before any planning
- **Explicit scope**: Plan only what KICKOFF.md authorizes
- **Auditable trail**: Every planned task traces back to KICKOFF.md sections
- **Lifecycle awareness**: PLAN.md and TODO.md have explicit status fields
- **Human gate**: Both artifacts require approval before `asi-exec` proceeds

---

## Deterministic Surface

### Mechanisms

| Mechanism | Inputs | Outputs | Failure Conditions | Idempotent |
| --------- | ------ | ------- | ------------------ | ---------- |
| KICKOFF.md existence check | File path | Boolean | File not found | Yes |
| KICKOFF.md frontmatter parse | File content | Structured data | Invalid YAML, missing fields | Yes |
| KICKOFF.md status validation | `status` field | Boolean (approved?) | Status not `approved` | Yes |
| PLAN.md existence check | File path | Boolean | N/A | Yes |
| TODO.md existence check | File path | Boolean | N/A | Yes |
| Section extraction | KICKOFF.md content | Parsed sections | Missing required sections | Yes |
| Task ordering validation | TODO.md content | Dependency graph validity | Circular dependencies | Yes |

### Observable Signals

- **Exit codes**: 0 = success, 1 = precondition failure, 2 = invalid input
- **Files produced**: `PLAN.md`, `TODO.md`
- **Frontmatter fields**: `status`, `timestamp`, `source_kickoff`
- **Validation**: Scripts verify artifact structure

### Partial Determinism Declaration

The following are deterministic up to a point:

| Mechanism | Deterministic Portion | Judgment Portion |
| --------- | --------------------- | ---------------- |
| Task decomposition | Section boundaries from KICKOFF.md | Granularity of individual tasks |
| Dependency ordering | Explicit dependencies in KICKOFF.md | Implicit ordering decisions |
| Risk assessment | Risks stated in KICKOFF.md | Severity classification |

---

## Judgment Remainder

### Items requiring judgment

| Decision | Why Not Deterministic | Category | Blocking Reason |
| -------- | --------------------- | -------- | --------------- |
| Task granularity | No universal rule for decomposition depth | Heuristic selection | Context-dependent |
| Task descriptions | Natural language synthesis | Editorial | Summarization required |
| Dependency inference | Some dependencies implicit | Interpretation | Not all stated in KICKOFF.md |
| Risk severity | Subjective assessment | Heuristic selection | No objective scale |
| Implementation order | Multiple valid sequences | Multiple valid outcomes | Trade-offs exist |

### Disallowed shortcuts

- Do not invent tasks not traceable to KICKOFF.md
- Do not merge unrelated KICKOFF.md sections into single tasks
- Do not assume dependencies not stated or clearly implied
- Do not classify all risks as "low" to avoid analysis
- Do not create circular dependencies to defer decisions

---

## Schema Designs

### Intent Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Plan Intent Schema",
  "type": "object",
  "required": ["source_kickoff", "target_directory"],
  "properties": {
    "source_kickoff": {
      "type": "string",
      "description": "Path to approved KICKOFF.md"
    },
    "target_directory": {
      "type": "string",
      "description": "Directory for PLAN.md and TODO.md output"
    }
  }
}
```

### Execution Plan Schema (PLAN.md frontmatter)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Plan Artifact Schema",
  "type": "object",
  "required": ["description", "timestamp", "status", "source_kickoff"],
  "properties": {
    "description": { "type": "string" },
    "timestamp": { "type": "string", "format": "date-time" },
    "status": { "enum": ["draft", "review", "approved", "rejected"] },
    "source_kickoff": { "type": "string" },
    "skill_name": { "type": "string" }
  }
}
```

### Result Schema (TODO.md structure)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "TODO Artifact Schema",
  "type": "object",
  "required": ["description", "timestamp", "status", "tasks"],
  "properties": {
    "description": { "type": "string" },
    "timestamp": { "type": "string", "format": "date-time" },
    "status": { "enum": ["draft", "review", "approved", "rejected"] },
    "source_plan": { "type": "string" },
    "tasks": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "description", "status"],
        "properties": {
          "id": { "type": "string" },
          "description": { "type": "string" },
          "status": { "enum": ["pending", "in_progress", "done"] },
          "depends_on": { "type": "array", "items": { "type": "string" } },
          "source_section": { "type": "string" }
        }
      }
    }
  }
}
```

---

## Open Questions

- [ ] Should PLAN.md include time estimates, or is that scope creep?
  - No time estimates. They are often predicted by agents based on how long it takes a human to do something. Agents are fast. We could add difficulty, but this is too subjective. Consider this out of scope.
- [ ] Should TODO.md support sub-tasks, or keep flat for simplicity?
  - Keep it flat.
- [ ] What happens if KICKOFF.md is modified after PLAN.md is created?
  - It should flagged, and the agent should reason about whether htep lan needs to be modified to align with the updated kickoff. This is where chrono awareness and change detection makes agents thrive.
- [ ] Should there be a mechanism to regenerate TODO.md from PLAN.md?
  - The PLAN must be highly structured and based off of a schema. PLAN is derived from KICKOFF, and TODO is derived from PLAN. If KICKOFF is invalidated, than the PLAN is invalidated, then the TODO is invalidated.
- [ ] How should `asi-plan` handle KICKOFF.md with `status: review` (not yet approved)?
  - The KICKOFF.md should be approved before `asi-plan` proceeds. The agnet should request approval from the user, or recommend it to the user (preferably). Determinism should be used to parse the frontmatter and update the status field.
- [ ] Should validation scripts enforce task-to-KICKOFF traceability?
  - Yes. The agent should reason about whether the tasks in TODO.md are traceable to the sections in KICKOFF.md.
