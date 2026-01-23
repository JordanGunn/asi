# Procedure

## Prerequisites

1. Confirm `.asi/kickoff/` directory exists
2. Confirm `.asi/kickoff/KICKOFF.md` exists with `status: approved`
3. Confirm `.asi/kickoff/SKILL_TYPE.json` exists and is valid
4. Confirm `.asi/kickoff/SCAFFOLD.json` exists and is valid
5. Create `.asi/plan/` directory if it does not exist

---

## Step 1: Parse Kickoff Artifacts

### 1a. Parse KICKOFF.md

1. Read `.asi/kickoff/KICKOFF.md`
2. Parse frontmatter and validate required fields
3. Extract all body sections
4. Verify all required sections are present:
   - Purpose
   - Deterministic Surface
   - Judgment Remainder
   - Schema Designs

### 1b. Parse SKILL_TYPE.json

1. Read `.asi/kickoff/SKILL_TYPE.json`
2. Validate against `skill_type_v1.schema.json`
3. Extract `type` (single or grouped)

### 1c. Parse SCAFFOLD.json

1. Read `.asi/kickoff/SCAFFOLD.json`
2. Validate against appropriate schema based on skill type
3. Extract directory structure and file list

**Output:** Structured representation of all kickoff artifacts

---

## Step 2: Decompose into PLAN.md

For each KICKOFF.md section, derive implementation details:

### From Purpose

- Extract skill boundaries and non-goals
- Document governing principles

### From Deterministic Surface

- List scripts to create
- List assets to produce
- Define validation mechanisms

### From Judgment Remainder

- Identify risks and their severity
- Document mitigation approaches

### From Schema Designs

- List schema files to create
- List template files to create

### From Open Questions

- Document deferred decisions
- Note blocking questions

**Output:** PLAN.md with all required sections

---

## Step 3: Generate TODO.md from SCAFFOLD.json

1. Parse `SCAFFOLD.json` to extract all directories and files to create
2. For each directory: create a scaffolding task
3. For each file: create a file creation task with template reference
4. Convert PLAN.md sections into additional ordered tasks
5. Assign unique task IDs (e.g., `T001`, `T002`)
6. Set all tasks to `status: pending`
7. Add dependencies where applicable
8. Reference source (KICKOFF.md section or SCAFFOLD.json) for each task

**Output:** TODO.md with ordered task list derived from kickoff artifacts

---

## Step 4: Produce Artifacts

1. Ensure `.asi/plan/` directory exists
2. Populate PLAN.md frontmatter from template
3. Populate TODO.md frontmatter from template
4. Set both to `status: draft`
5. Set `timestamp` to current ISO 8601
6. Write `.asi/plan/PLAN.md`
7. Write `.asi/plan/TODO.md`
8. Report completion status

---

## Completion Criteria

- [ ] `.asi/kickoff/KICKOFF.md` was approved before proceeding
- [ ] `.asi/kickoff/SKILL_TYPE.json` was parsed
- [ ] `.asi/kickoff/SCAFFOLD.json` was parsed
- [ ] `.asi/plan/PLAN.md` exists with valid frontmatter
- [ ] `.asi/plan/PLAN.md` has all required sections
- [ ] `.asi/plan/TODO.md` exists with valid frontmatter
- [ ] `.asi/plan/TODO.md` tasks trace to kickoff artifacts
- [ ] No implementation or code was produced
- [ ] Both artifacts have `status: draft`
