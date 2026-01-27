# Procedure

Execute onboarding using the deterministic-first flow below.

---

## Execution Model

```text
Script (init.sh)       → Creates onboarding artifacts and state
Agent (per step)       → Produces JSON conforming to step schema
Script (inject.sh)     → Appends step output into NOTES.md/SOURCES.md
Script (checkpoint.sh) → Validates step, gates progression
```

The agent should keep onboarding scoped to the user’s current goal and avoid planning or implementation.

---

## Step 0: Deterministic Preamble (REQUIRED)

Recommended (environment check):

```bash
scripts/bootstrap.sh --check
```

Then initialize (idempotent):

```bash
scripts/init.sh --topic "<short topic>"
```

This creates:

- `.asi/onboard/NOTES.md`
- `.asi/onboard/SOURCES.md`
- `.asi/onboard/STATE.json`

---

## Step 1: Read Entry Points

Read the canonical entrypoints and summarize only what matters for the topic:

- `llms.txt`
- `docs/manifesto/.INDEX.md`
- `docs/design/.INDEX.md`

Produce `.asi/onboard/step_1_output.json` conforming to the step schema, then inject and checkpoint:

```bash
scripts/inject.sh --step 1 --input .asi/onboard/step_1_output.json
scripts/checkpoint.sh --step 1 --advance
```

---

## Step 2: Focused Deepening (Optional, repeatable)

Read the minimal additional docs needed for the topic (example: `docs/design/specs/.INDEX.md` for skill changes).

Write `.asi/onboard/step_2_output.json`, then:

```bash
scripts/inject.sh --step 2 --input .asi/onboard/step_2_output.json
scripts/checkpoint.sh --step 2 --advance
```

---

## Step 3: Open Questions and Handoff

Capture:

- open questions that must be answered before planning
- constraints/invariants to carry into `asi-plan`
- recommended next action (usually `asi-plan`)

Write `.asi/onboard/step_3_output.json`, then:

```bash
scripts/inject.sh --step 3 --input .asi/onboard/step_3_output.json
scripts/checkpoint.sh --step 3 --advance
```

---

## Completion Criteria

- [ ] `scripts/validate.sh --check all` passes
- [ ] NOTES.md contains a concise context digest for the topic
- [ ] SOURCES.md lists consulted sources and why they matter
- [ ] No kickoff/plan/exec artifacts were created
- [ ] No implementation occurred

