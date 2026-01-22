# Procedure

## Prerequisites

1. Confirm KICKOFF.md path is provided or discoverable
2. Confirm KICKOFF.md exists and is readable
3. Confirm KICKOFF.md has `status: approved`
4. Confirm target directory exists and is writable

---

## Step 1: Parse KICKOFF.md

1. Read KICKOFF.md content
2. Parse frontmatter and validate required fields
3. Extract all body sections
4. Verify all required sections are present:
   - Purpose
   - Deterministic Surface
   - Judgment Remainder
   - Schema Designs
   - Open Questions

**Output:** Structured representation of KICKOFF.md

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

## Step 3: Generate TODO.md

1. Convert PLAN.md sections into ordered tasks
2. Assign unique task IDs (e.g., `T001`, `T002`)
3. Set all tasks to `status: pending`
4. Add dependencies where applicable
5. Reference source KICKOFF.md section for each task

**Output:** TODO.md with ordered task list

---

## Step 4: Produce Artifacts

1. Populate PLAN.md frontmatter from template
2. Populate TODO.md frontmatter from template
3. Set both to `status: draft`
4. Set `timestamp` to current ISO 8601
5. Write both artifacts
6. Report completion status

---

## Completion Criteria

- [ ] KICKOFF.md was approved before proceeding
- [ ] PLAN.md exists with valid frontmatter
- [ ] PLAN.md has all required sections
- [ ] TODO.md exists with valid frontmatter
- [ ] TODO.md tasks trace to KICKOFF.md sections
- [ ] No implementation or code was produced
- [ ] Both artifacts have `status: draft`
