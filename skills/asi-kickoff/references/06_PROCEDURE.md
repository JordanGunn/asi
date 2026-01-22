# Procedure

## Prerequisites

1. Confirm skill name is explicitly provided
2. Confirm skill purpose is explicitly provided
3. Confirm target directory exists and is writable
4. Read ASI kickoff documents at `assets/procedure/`

---

## Step 1: Purpose Definition

Document the skill's purpose following `assets/procedure/01_PURPOSE.md`:

- What the skill does
- What problem it solves
- What it does NOT do
- Governing ASI principles

**Output:** Purpose section in KICKOFF.md

---

## Step 2: Deterministic Surface Mapping

Following `assets/procedure/03_DETERMINISTIC_COVERAGE.md`:

- Identify all mechanisms that can be made deterministic
- Document inputs, outputs, failure conditions
- Document idempotent behavior and observable signals
- Mark partial determinism explicitly

**Output:** Deterministic Surface section in KICKOFF.md

---

## Step 3: Judgment Remainder

Following `assets/procedure/04_SUBJECTIVE_REMAINDER.md`:

- Identify what cannot be made deterministic
- Classify each item by judgment category
- Document blocking reason for each
- Document disallowed shortcuts

**Output:** Judgment Remainder section in KICKOFF.md

---

## Step 4: Schema Design

Following `assets/procedure/05_REASONING_SCHEMAS.md`:

- Design intent schema (shape only)
- Design execution plan schema (shape only)
- Design result/receipt schema (shape only)
- Ensure schemas are host-agnostic

**Output:** Schema Designs section in KICKOFF.md

---

## Step 5: Open Questions

Following `assets/procedure/07_OPEN_QUESTIONS.md`:

1. Create `QUESTIONS.md` from template (`assets/templates/QUESTIONS.template.md`)
2. Surface ambiguous requirements
3. Surface missing constraints
4. Surface conflicting goals
5. Do NOT answer — capture only
6. Set `status: unresolved` in frontmatter

**Output:** `QUESTIONS.md` as sibling to `KICKOFF.md`

### Resolution Flow

1. Agent produces `QUESTIONS.md` with open questions
2. User answers inline below each question
3. Agent reads `QUESTIONS.md` and incorporates answers
4. Agent marks questions `[x]` when incorporated
5. Agent updates `status: resolved` when all questions addressed

---

## Step 6: Produce Artifact

1. Populate frontmatter from template
2. Set `status: draft`
3. Set `timestamp` to current ISO 8601
4. Write all sections to KICKOFF.md
5. Report completion status

---

## Completion Criteria

- [ ] KICKOFF.md exists with valid frontmatter
- [ ] All five body sections are present
- [ ] No implementation or code was produced
- [ ] Open questions are captured, not answered
- [ ] Status is `draft` pending human review
