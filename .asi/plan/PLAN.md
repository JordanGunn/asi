---
description: "Implementation plan for plan"
timestamp: "2026-01-23T20:37:35Z"
status: approved
source_kickoff: ".asi/kickoff/KICKOFF.md"
source_kickoff_hash: "61e8171332b2ffef6ad14372d2331c808a54d2a7be99e05d0f601fdbb11cfbe1"
skill_name: "plan"
step: 8
---

# Plan: plan

## Scripts

| Script | Purpose | Inputs | Outputs |
| ------ | ------- | ------ | ------- |
| init.sh | Create new plan with name and initial structure | --name <plan-name> [--force] | .plan/active.yaml, .plan/active/STATE.json |
| add-step.sh | Add a step to the active plan | --step <description> [--after <step-id>] | Updated .plan/active.yaml |
| update-status.sh | Update step status | --step <step-id> --status <pending|in_progress|done|skipped> | Updated .plan/active.yaml, STATE.json log entry |
| status.sh | Display current plan status | [--format <json|text>] | Plan summary to stdout |
| archive.sh | Archive completed plan and clear active | [--force] | .plan/archive/<timestamp>/ |
| validate.sh | Validate plan schema and structure | --check <prereqs|schema|steps|all> | Validation result to stdout |

---
## Assets

### Schemas

| Schema | Purpose |
| ------ | ------- |
| plan_v1.schema.json | Validates .plan/active.yaml structure |
| plan_intent_v1.schema.json | Validates agent intent before script execution |
| plan_result_v1.schema.json | Validates script output receipts |

### Templates

| Template | Purpose |
| -------- | ------- |
| active.template.yaml | Template for new plan creation |

---
## Validation

| Mechanism | What it validates | Failure behavior |
| --------- | ----------------- | ---------------- |
| validate.sh --check prereqs | Plan directory exists, no conflicting active plan | Exit 1 with error message |
| validate.sh --check schema | active.yaml conforms to plan_v1.schema.json | Exit 1 with schema violation details |
| validate.sh --check steps | All steps have valid IDs, statuses, no duplicates | Exit 1 with step errors |
| validate.sh --check all | All above checks | Exit 1 on first failure |

---
## Boundaries

### In scope

- Create new plans with unique names
- Add steps to active plan
- Update step status (pending, in_progress, done, skipped)
- Display plan status in JSON or text format
- Archive completed plans with timestamp
- Validate plan schema and structure
- Persist state across sessions via STATE.json
- Support optional sub-steps when agent deems helpful

### Out of scope

- Task implementation — only tracking
- Dependency management between steps
- External tool integration
- Time estimates or scheduling
- Multi-plan management (one active plan at a time)

---
## Non-goals

<!-- AGENT: Fill from KICKOFF_PARSED.json purpose -->

---

## Risks

| Risk | Severity | Mitigation |
| ---- | -------- | ---------- |
| Agent invents steps not requested by user | medium | 04_NEVER.md prohibits inferring steps; validation script can flag suspiciously many steps |
| Plan file corruption from concurrent access | low | Single-agent design; scripts use atomic write patterns |
| Stale plan state after session resumption | low | STATE.json provides full history; status.sh shows current state |

---
## Lifecycle

### Artifacts produced

- .plan/active.yaml — Active plan definition
- .plan/active/STATE.json — Execution log and state
- .plan/archive/<timestamp>/ — Archived completed plans

### Status flow

active → completed (all steps done/skipped) → archived

### Human gates

- User approval not required for plan operations
- User consent required for: skipping steps, archiving with incomplete steps
