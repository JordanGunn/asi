# Changelog

All notable changes to this specification will be documented in this file.

## 0.2.0

### Documentation

- Removed all MCP (Model Context Protocol) references—ASI is protocol-agnostic
- Created `docs/SKILLS.md` with consolidated skill design pipeline documentation
- Added "Two Paths" quick start:
  - README now presents "Just Use It" vs "Understand It" choice upfront
  - `llms.txt` updated with direct skill invocation instructions
  - SKILLS.md includes TL;DR invocation examples
- Updated README with:
  - New overview section explaining ASI's purpose
  - Mermaid execution flow diagram
  - Layer explanation table
  - Refined "What ASI Defines" section
- Expanded glossary with core ASI terms:
  - Determinism / Deterministic
  - Judgment contract
  - Qualitative judgment
  - Quantitative outcome
  - Reasoning contract
  - Skill
  - Subjective reasoning

### asi-kickoff (v0.2.0)

Refactored to enforce deterministic-first execution:

- **New scripts:**
  - `init.sh` — Deterministic preamble; creates structure and populates known values
  - `inject.sh` — Injects schema-constrained JSON into KICKOFF.md sections
  - `checkpoint.sh` — Per-step validation gates progression
- **New schemas:**
  - `step_output_v1.schema.json` — Constrains agent output per procedure step
- **Updated procedure:**
  - Scripts handle all file I/O; agent produces data only
  - Per-step validation before progression
  - STATE.json tracks procedure progress
- **Execution model:** `Script (init) → Agent (JSON) → Script (inject) → Script (checkpoint)`

### asi-plan (v0.2.0)

Refactored to enforce deterministic-first execution and proper kickoff ingestion:

- **New scripts:**
  - `init.sh` — Validates kickoff-approved, parses all kickoff artifacts into KICKOFF_PARSED.json
  - `generate-tasks.sh` — Deterministically generates tasks from SCAFFOLD.json
  - `inject.sh` — Injects schema-constrained JSON into PLAN.md/TODO.md sections
  - `checkpoint.sh` — Per-step validation gates progression
- **New schemas:**
  - `step_output_v1.schema.json` — Constrains agent output per procedure step
- **New artifacts:**
  - `KICKOFF_PARSED.json` — Structured representation of kickoff (agent reasons over this, not raw markdown)
  - `tasks_scaffold.json` — Deterministically generated task list from scaffold
- **Updated procedure:**
  - Agent reasons over parsed JSON, not raw markdown
  - Scaffold tasks are generated deterministically, not invented
  - Drift detection via source_kickoff_hash
- **Execution model:** `Script (init) → Script (generate-tasks) → Agent (JSON) → Script (inject) → Script (checkpoint)`

### asi-exec (v0.2.0)

Refactored to enforce deterministic-first execution and proper plan ingestion:

- **New scripts:**
  - `init.sh` — Validates plan-approved, parses plan artifacts into PLAN_PARSED.json
  - `select-task.sh` — Deterministically selects next task, validates dependencies
  - `update-status.sh` — Updates TODO.md status (agent never edits TODO directly)
  - `append-receipt.sh` — Appends formatted receipt to RECEIPT.md
  - `checkpoint.sh` — Per-task validation, drift detection, state checks
- **New schemas:**
  - `task_output_v1.schema.json` — Constrains agent output per task execution
- **New artifacts:**
  - `PLAN_PARSED.json` — Structured representation of plan (agent reasons over this)
  - `task_*_output.json` — Per-task execution output
  - `task_*_receipt.json` — Per-task receipt before append
- **Updated procedure:**
  - Agent implements tasks but never edits TODO.md
  - Task selection and dependency validation is scripted
  - Status updates are deterministic (scripts only)
  - Receipts appended by script for consistent formatting
- **Execution model:** `Script (init) → Script (select-task) → Script (update-status) → Agent (execute) → Script (append-receipt) → Script (checkpoint)`

## 0.1.0

- Initial draft of the ASI manifesto and design specifications.
