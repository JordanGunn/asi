# Procedure

Execute the kickoff procedure using the deterministic-first flow below.

---

## Execution Model

```text
Script (init.sh)     → Creates structure, populates known values
Agent (per step)     → Produces JSON conforming to step schema
Script (inject.sh)   → Injects JSON into KICKOFF.md
Script (checkpoint)  → Validates step, gates progression
```

The agent reasons **only** within schema-constrained boundaries. Scripts handle all file I/O.

---

## Step 0: Deterministic Preamble (REQUIRED)

**Before any agent reasoning**, run the initialization script:

Recommended (environment check):

```bash
scripts/bootstrap.sh --check
```

Bootstrap is a **user-run** helper. The agent may recommend it, but should not execute it.

```bash
scripts/init.sh --skill-name "<name>" --skill-purpose "<purpose>"
```

This creates:

- `.asi/kickoff/KICKOFF.md` — Template with known values populated
- `.asi/kickoff/QUESTIONS.md` — Empty questions file
- `.asi/kickoff/SKILL_TYPE.json` — Scaffold decision (agent fills)
- `.asi/kickoff/SCAFFOLD.json` — Directory structure (agent fills)
- `.asi/kickoff/STATE.json` — Procedure progress tracker

**Do not skip this step. Do not have the agent create these files.**

---

## Steps 1-6: Agent Reasoning (Schema-Constrained)

For each step, the agent:

1. Reads the procedure doc (`assets/procedure/0N_*.md`)
2. Produces JSON conforming to `assets/schemas/step_output_v1.schema.json`
3. Saves output to `.asi/kickoff/step_N_output.json`

Then the script injects it:

```bash
scripts/inject.sh --step N --input .asi/kickoff/step_N_output.json
scripts/checkpoint.sh --step N --advance
```

### Step Sequence

| Step | Procedure Doc | Agent Output | Validation |
|------|---------------|--------------|------------|
| 1 | `01_PURPOSE.md` | Purpose section content | Purpose section filled |
| 2 | `02_SCAFFOLD.md` | Single/grouped decision | SKILL_TYPE.json valid |
| 3 | `03_DETERMINISTIC_COVERAGE.md` | Mechanisms + signals | Surface section filled |
| 4 | `04_SUBJECTIVE_REMAINDER.md` | Judgment items | Remainder section filled |
| 5 | `05_REASONING_SCHEMAS.md` | Intent/Plan/Result schemas | 3 schemas present |
| 6 | `07_OPEN_QUESTIONS.md` | Captured questions | QUESTIONS.md updated |

---

## Completion Criteria

- [ ] `scripts/validate.sh --check all` passes
- [ ] STATE.json shows all steps complete
- [ ] KICKOFF.md has valid frontmatter and all sections
- [ ] No implementation or code was produced
- [ ] Status is `draft` pending human review

---

## Why This Flow?

1. **Scripts handle known values** — Timestamp, structure, headers are deterministic
2. **Agent surface is minimal** — Only subjective content requires reasoning
3. **Schemas constrain output** — Agent cannot drift outside declared shape
4. **Checkpoints gate progression** — Each step validated before next begins
5. **All I/O is scripted** — Agent produces data, scripts write files
