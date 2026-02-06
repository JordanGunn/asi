# Changelog

All notable changes to this specification will be documented in this file.

## [Unreleased]

### Added

- Added `docs/implementation/` documentation suite:
  - implementation invariants, decision records, benchmark rationale, maintainer compliance checklist, legacy migration playbook
  - claims/evidence matrix, threat model + non-goals, and measurement protocol
- Added `docs/tutorial/` step-by-step tutorial suite for designing a grep-style ASI skill interface surface
- Added `skills/install.sh` and `skills/install.ps1` installer scripts for the ASI CLI
- Added creator schema discoverability endpoints:
  - `asi creator suggest --schema`
  - `asi creator apply --schema`

### Changed

- Relocated active ASI CLI source from `cli/` to `skills/cli/`
- Updated `asi-creator` wrappers to support schema targets:
  - `schema` (default run)
  - `schema suggest`
  - `schema apply`
- Expanded `asi creator next` `option_constraints` with complete required field and length metadata
- Clarified creator loop requirements by exposing `recommended_option_range: [1, 3]`
- Updated creator procedure reference to include concrete JSON input shapes for `suggest --stdin` and `apply --stdin`
- Updated README/design/llms cross-links to include implementation documentation entrypoints

### Fixed

- Fixed mismatch between emitted `option_constraints` and validated suggestion payload fields:
  - replaced incorrect `required_tradeoff_field`
  - added correct `required_impact_field` and full required field set
- Fixed creator suggestion validation to allow meaningful recommendations (`recommended` now supports `1..3`)
- Fixed creator suggest response to preserve provided `recommended` value instead of hardcoding `1`
- Fixed creator CLI test pathing to use `skills/cli/src` for PYTHONPATH

## 0.3.0

### Documentation

- Added `asi-onboard` as an optional, disk-backed context/bootstrap skill
- Updated skill pipeline docs to reflect unified kickoff+plan interface
- Fixed Windsurf workflow skill paths under `.windsurf/workflows/`

### asi-plan (v0.3.0)

- `asi-plan` now served as the unified kickoff + planning entrypoint (legacy).
  - If kickoff was missing/unapproved: complete kickoff via kickoff-phase scripts
  - After kickoff approval: generate PLAN.md + TODO.md as before
- Added `kickoff-*` kickoff-phase scripts (legacy)

### asi-onboard (v0.1.0)

- New skill for scoped doc exploration and disk-backed context capture:
  - `.asi/onboard/NOTES.md`, `.asi/onboard/SOURCES.md`, `.asi/onboard/STATE.json`

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

### asi-kickoff (v0.2.0) [legacy]

Refactored to enforce deterministic-first execution:

- **New scripts:**
  - `init.sh` — Deterministic preamble; creates structure and populates known values
  - `inject.sh` — Injects schema-constrained JSON into KICKOFF.md sections
  - `checkpoint.sh` — Per-step validation gates progression
- **New schemas:**
  - CLI-emitted step output schema — Constrains agent output per procedure step
- **Updated procedure:**
  - Scripts handle all file I/O; agent produces data only
  - Per-step validation before progression
  - STATE.json tracks procedure progress
- **Execution model:** `Script (init) → Agent (JSON) → Script (inject) → Script (checkpoint)`

### asi-plan (v0.2.0) [legacy]

Refactored to enforce deterministic-first execution and proper kickoff ingestion:

- **New scripts:**
  - `init.sh` — Validates kickoff-approved, parses all kickoff artifacts into KICKOFF_PARSED.json
  - `generate-tasks.sh` — Deterministically generates tasks from SCAFFOLD.json
  - `inject.sh` — Injects schema-constrained JSON into PLAN.md/TODO.md sections
  - `checkpoint.sh` — Per-step validation gates progression
- **New schemas:**
  - CLI-emitted step output schema — Constrains agent output per procedure step
- **New artifacts:**
  - `KICKOFF_PARSED.json` — Structured representation of kickoff (agent reasons over this, not raw markdown)
  - `tasks_scaffold.json` — Deterministically generated task list from scaffold
- **Updated procedure:**
  - Agent reasons over parsed JSON, not raw markdown
  - Scaffold tasks are generated deterministically, not invented
  - Drift detection via source_kickoff_hash
- **Execution model:** `Script (init) → Script (generate-tasks) → Agent (JSON) → Script (inject) → Script (checkpoint)`

### asi-exec (v0.2.0) [legacy]

Refactored to enforce deterministic-first execution and proper plan ingestion:

- **New scripts:**
  - `init.sh` — Validates plan-approved, parses plan artifacts into PLAN_PARSED.json
  - `select-task.sh` — Deterministically selects next task, validates dependencies
  - `update-status.sh` — Updates TODO.md status (agent never edits TODO directly)
  - `append-receipt.sh` — Appends formatted receipt to RECEIPT.md
  - `checkpoint.sh` — Per-task validation, drift detection, state checks
- **New schemas:**
  - CLI-emitted task output schema — Constrains agent output per task execution
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
