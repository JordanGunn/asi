# Procedure

Execute the planning procedure using the deterministic-first flow below.

---

## Execution Model

```text
Script (kickoff-*.sh)      → (If needed) produce/advance kickoff artifacts
Script (init.sh)           → Validates prereqs, parses kickoff, creates templates
Script (generate-tasks.sh) → Scaffold → tasks_scaffold.json (deterministic)
Agent (per step)           → Produces JSON conforming to step schema
Script (inject.sh)         → Injects JSON into PLAN.md/TODO.md
Script (checkpoint.sh)     → Validates step, gates progression
```

The agent reasons **only** over parsed kickoff data (`KICKOFF_PARSED.json`). Scripts handle all file I/O.

---

## Kickoff Phase (if needed)

If KICKOFF.md is missing or not yet approved, complete the kickoff phase first using the kickoff-phase scripts in this skill.

Optional (recommended): if you need to build context before designing/planning, run `asi-onboard` first. `asi-plan` does not require onboarding artifacts.

Recommended (environment check):

```bash
scripts/kickoff-bootstrap.sh --check
```

Initialize kickoff artifacts:

```bash
scripts/kickoff-init.sh --skill-name "<name>" --skill-purpose "<purpose>"
```

Then follow the kickoff step progression (checkpointing each step) and mark approval:

```bash
scripts/kickoff-checkpoint.sh --step N --advance
scripts/kickoff-approve.sh
```

After KICKOFF.md is `approved`, proceed to Step 0.

---

## Step 0: Deterministic Preamble (REQUIRED)

**Before any agent reasoning**, run the initialization script:

Recommended (environment check):

```bash
scripts/bootstrap.sh --check
```

Bootstrap is a **user-run** helper. The agent may recommend it, but should not execute it.

```bash
scripts/init.sh
```

This:

- Validates prerequisites (KICKOFF.md approved, all artifacts exist)
- Parses all kickoff artifacts into `.asi/plan/KICKOFF_PARSED.json`
- Creates PLAN.md and TODO.md templates with known values
- Computes `source_kickoff_hash` for drift detection
- Creates STATE.json to track progress

**Do not skip this step. Do not have the agent parse kickoff files directly.**

---

## Step 1: Generate Scaffold Tasks (Deterministic)

Run the task generation script:

```bash
scripts/generate-tasks.sh
```

This deterministically generates tasks from SCAFFOLD.json → `tasks_scaffold.json`.

The agent reviews this output but does not invent tasks from scratch.

Validate:

```bash
scripts/checkpoint.sh --step 1 --advance
```

---

## Steps 2-7: Agent Reasoning (Schema-Constrained)

For each step, the agent:

1. Reads `KICKOFF_PARSED.json` (not raw markdown)
2. Produces JSON conforming to `assets/schemas/step_output_v1.schema.json`
3. Saves output to `.asi/plan/step_N_output.json`

Then the script injects it:

```bash
scripts/inject.sh --step N --input .asi/plan/step_N_output.json
scripts/checkpoint.sh --step N --advance
```

### Step Sequence

| Step | Section | Source in KICKOFF_PARSED.json |
|------|---------|-------------------------------|
| 2 | Scripts | `sections.deterministic_surface` |
| 3 | Assets | `sections.schema_designs` |
| 4 | Validation | `sections.deterministic_surface` |
| 5 | Boundaries | `sections.purpose` |
| 6 | Risks | `sections.judgment_remainder` |
| 7 | Lifecycle | derived from all sections |

---

## Step 8: Finalize TODO.md

The agent:

1. Reviews `tasks_scaffold.json` (from Step 1)
2. Adds additional tasks derived from PLAN.md sections
3. Ensures all tasks have `source_section` traceability
4. Produces final task list as JSON

```bash
scripts/inject.sh --step 8 --input .asi/plan/step_8_output.json
scripts/checkpoint.sh --step 8 --advance
```

---

## Completion Criteria

- [ ] `scripts/validate.sh --check all` passes
- [ ] STATE.json shows all steps complete
- [ ] PLAN.md has valid frontmatter and all sections
- [ ] TODO.md has task table with traceability
- [ ] All tasks trace to KICKOFF.md sections
- [ ] No implementation or code was produced
- [ ] Both artifacts have `status: draft`

---

## Why This Flow?

1. **Scripts parse kickoff** — Agent reasons over structured JSON, not raw markdown
2. **Scaffold tasks are deterministic** — Generated from SCAFFOLD.json, not invented
3. **Schemas constrain output** — Agent cannot drift outside declared shape
4. **Checkpoints gate progression** — Each step validated before next begins
5. **All I/O is scripted** — Agent produces data, scripts write files
6. **Drift detection** — Hash comparison catches KICKOFF.md changes
