---
description: "Skill design kickoff for plan"
timestamp: "2026-01-23T20:29:39Z"
status: approved
skill_name: "plan"
skill_purpose: "Agent-optimized planning skill for agentic-supported programming sessions. Creates, manages, and tracks structured plans with deterministic state management."
step: 6
---

# Kickoff: plan

## Purpose

### What this skill does

Creates, manages, and tracks structured execution plans for agentic programming sessions. Provides deterministic plan lifecycle management (create, update, execute, archive) with schema-validated artifacts. Enables agents to break complex tasks into ordered steps, track progress, and maintain state across conversation boundaries.

### What problem it solves

Agents currently lack persistent, structured planning mechanisms. Plans are often ad-hoc, lost between sessions, or inconsistently formatted. This skill provides: (1) A canonical plan format with schema validation, (2) Deterministic state management for multi-step tasks, (3) Progress tracking that survives session boundaries, (4) Clear handoff artifacts for resumption.

### What this skill does NOT do

- Does NOT implement tasks — only tracks them
- Does NOT make judgment calls about task ordering — user or upstream skill decides
- Does NOT manage dependencies between tasks — flat list only
- Does NOT integrate with external project management tools
- Does NOT provide time estimates or scheduling

### Governing ASI principles

- Determinism first: All plan operations are scripted with predictable outcomes
- Schema-validated artifacts: Plan format is enforced, not suggested
- Minimal judgment: Agent role is constrained to user intent translation
- State persistence: Plan state survives agent restarts and session boundaries
- Auditability: All plan mutations are logged with timestamps

---
## Deterministic Surface

### Mechanisms

| Mechanism | Inputs | Outputs | Failure Conditions | Idempotent |
| --------- | ------ | ------- | ------------------ | ---------- |
| init.sh | --name <plan-name> | .plan/active.yaml, .plan/active/STATE.json | Plan already exists without --force, Invalid plan name | yes (with --force) |
| add-step.sh | --step <description>, --after <step-id> | Updated .plan/active.yaml | No active plan, Invalid step-id reference | no (appends) |
| update-status.sh | --step <step-id>, --status <pending|in_progress|done|skipped> | Updated .plan/active.yaml, Log entry in STATE.json | Step not found, Invalid status transition | yes |
| status.sh | --format <json|text> | Plan status to stdout | No active plan | yes (read-only) |
| archive.sh |  | .plan/archive/<timestamp>/, Cleared .plan/active/ | No active plan, Incomplete tasks without --force | no |
| validate.sh | --check <prereqs|schema|steps|all> | Validation result to stdout | Schema violation, Missing required fields | yes (read-only) |

### Observable Signals

- Plan file exists at .plan/active.yaml
- STATE.json contains execution log with timestamps
- Each step has unique ID and status field
- Archive directory contains timestamped plan snapshots

### Coverage Assessment

High deterministic coverage. All plan mutations go through scripts. Agent reasoning limited to: (1) translating user intent to step descriptions, (2) deciding when to mark steps complete.

---
## Judgment Remainder

### Items requiring judgment

| Decision | Why Not Deterministic | Category | Blocking Reason |
| -------- | --------------------- | -------- | --------------- |
| Step description wording | User intent must be translated to actionable step text | interpretation | none |
| When to mark step complete | Completion criteria may be implicit in user request | verification | none |
| Whether to skip a step | Context may indicate step is no longer relevant | triage | requires user consent |

### Disallowed shortcuts

- Do not infer steps not explicitly requested by user
- Do not auto-complete steps without verification
- Do not reorder steps without explicit consent
- Do not delete steps — only skip with consent
- Do not modify step descriptions after creation without consent

---
## Schema Designs

### Intent Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Plan Intent",
  "type": "object",
  "required": [
    "action"
  ],
  "properties": {
    "action": {
      "type": "string",
      "enum": [
        "create",
        "add-step",
        "update-status",
        "status",
        "archive"
      ]
    },
    "plan_name": {
      "type": "string",
      "description": "Required for create action"
    },
    "step_description": {
      "type": "string",
      "description": "Required for add-step action"
    },
    "step_id": {
      "type": "string",
      "description": "Required for update-status action"
    },
    "new_status": {
      "type": "string",
      "enum": [
        "pending",
        "in_progress",
        "done",
        "skipped"
      ]
    }
  }
}
```

### Execution Plan Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Active Plan",
  "type": "object",
  "required": [
    "name",
    "created_at",
    "status",
    "steps"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "completed",
        "archived"
      ]
    },
    "steps": {
      "type": "array",
      "items": {
        "type": "object",
        "required": [
          "id",
          "description",
          "status"
        ],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^S[0-9]{3}$"
          },
          "description": {
            "type": "string"
          },
          "status": {
            "type": "string",
            "enum": [
              "pending",
              "in_progress",
              "done",
              "skipped"
            ]
          },
          "created_at": {
            "type": "string",
            "format": "date-time"
          },
          "completed_at": {
            "type": "string",
            "format": "date-time"
          }
        }
      }
    }
  }
}
```

### Result Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Plan Operation Result",
  "type": "object",
  "required": [
    "action",
    "status",
    "timestamp"
  ],
  "properties": {
    "action": {
      "type": "string"
    },
    "status": {
      "type": "string",
      "enum": [
        "success",
        "failed",
        "no_change"
      ]
    },
    "timestamp": {
      "type": "string",
      "format": "date-time"
    },
    "plan_name": {
      "type": "string"
    },
    "step_id": {
      "type": "string"
    },
    "message": {
      "type": "string"
    },
    "summary": {
      "type": "object",
      "properties": {
        "total_steps": {
          "type": "integer"
        },
        "pending": {
          "type": "integer"
        },
        "in_progress": {
          "type": "integer"
        },
        "done": {
          "type": "integer"
        },
        "skipped": {
          "type": "integer"
        }
      }
    }
  }
}
```

---
## Open Questions

<!-- See QUESTIONS.md for full list -->

- [ ] Should plans support nested sub-steps or remain flat?
- [ ] Should there be a maximum number of steps per plan?
- [ ] How should plan resumption work across different agents/sessions?
