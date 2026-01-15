# Doctor — Diagnostic Protocol for Complex Codebases

## Problem

Modern codebases, especially monorepos and distributed systems, fail in ways that are **misleading**. Errors surface in one layer (e.g. backend), while the cause lives elsewhere (CI, Kubernetes, infra, config).

Humans and agents alike tend to:

* fixate on the wrong layer
* treat symptoms as causes
* rush to implementation before understanding
* confuse “the prompt” with “the real problem”

The result is wasted time, brittle fixes, and growing distrust in automation.

**Doctor** exists to slow this down, *without stalling progress*.

---

## What This Is

**Doctor** is a **diagnostic protocol**, implemented as a single, monolithic skill, that enforces an explicit epistemic workflow:

> *Listen → Triage → Examine → Diagnose → Propose Treatment*

It models the codebase as a *patient*, failures as *symptoms*, and investigation as *medicine*, not guessing.

It does **not** fix code.
It does **not** plan implementation.
It produces **clinical artifacts** that can be reviewed, reused, or handed off.

---

## Core Principles

1. **Symptoms are not causes**
   User descriptions are witness statements, not ground truth.

2. **Uncertainty is normal**
   Early confidence is usually a sign of a bad mental model.

3. **Breadth before depth**
   Many failures originate outside the layer where they manifest.

4. **Do no harm**
   No refactors, fixes, or execution unless explicitly requested.

5. **Determinism where possible, subjectivity where necessary**
   Scripts return facts; agents provide interpretation.

6. **Each run must stand alone**
   The skill must be useful even when invoked mid-conversation or in isolation.

---

## Mental Model (The Doctor Protocol)

| Medical Concept | Doctor Meaning                                 |
| --------------- | ---------------------------------------------- |
| Patient         | The codebase / system                          |
| Symptom         | Observed failure, error, or misbehavior        |
| Intake          | Translating user narrative into clinical facts |
| Triage          | Broad hypothesis surfacing + prioritization    |
| Exam            | Focused evidence gathering in one area         |
| Diagnosis       | Best current explanation (with confidence)     |
| Treatment       | Proposed response (artifact, not execution)    |

This metaphor is intentional:
it gives the agent **permission to challenge assumptions** without being adversarial.

---

## How It Works

Doctor maintains a **session** under `.doctor/` and progresses through a controlled lifecycle.

### 1. Initialize a Session

```bash
doctor init --patient "my-service"
```

Creates `.doctor/session.yaml` and establishes the investigative context.

---

### 2. Intake Symptoms (Listening, Not Acting)

```bash
doctor symptom "API returns 502 via ingress" --category error
```

(Optionally aliased as `doctor intake`.)

This step:

* records verbatim symptoms
* separates observation from user interpretation
* does **not** assume intent or request action

---

### 3. Surface the Landscape (Optional)

```bash
doctor surface
```

Deterministically scans for relevant files (code, manifests, CI, IaC)
to avoid “forgetting” that certain layers exist.

---

### 4. Gather Evidence (Deterministic Search)

```bash
doctor grep "connection timeout" --save
```

* Uses parameterized `grep`
* Excludes common noise directories
* Optionally snapshots evidence into `.doctor/evidence/`

Evidence is factual; interpretation comes later.

---

### 5. Form Hypotheses (Triage Thinking)

```bash
doctor hypothesize "Ingress misconfiguration" --confidence 60
```

Hypotheses are:

* plural
* ranked
* explicitly falsifiable

This is **triage**, not diagnosis.

---

### 6. Diagnose (Commit Carefully)

```bash
doctor diagnose "Ingress route mismatch" --confidence 80 --cause "Path rewrite error"
```

This collapses uncertainty *explicitly*:

* a best estimate
* with stated confidence
* knowing it may be wrong

---

### 7. Propose Treatment (Artifact Only)

```bash
doctor treat --option "Fix ingress path:Update rewrite rule:low"
```

Generates `.doctor/treatment.md`:

* includes diagnosis
* lists treatment options
* highlights risk and effort
* **does not execute anything**

This artifact can be handed to:

* humans
* `plan-create`
* other agents

---

## Artifacts

Doctor intentionally produces **few, durable artifacts**:

* `.doctor/session.yaml`
  Canonical investigative state

* `.doctor/evidence/*.md`
  Immutable evidence snapshots

* `.doctor/treatment.md`
  Diagnosis + proposed treatments

No long-lived “illness registry” by design.

---

## Constraints (By Design)

Doctor **will not**:

* implement fixes
* refactor code
* run destructive commands
* assume the user’s framing is correct
* collapse uncertainty silently

Doctor **will**:

* question assumptions
* record ambiguity
* prefer boring explanations
* stop when epistemic clarity is achieved

---

## Who This Is For

* Developers working in **monorepos**
* Teams debugging **distributed systems**
* Agents that need **guardrails against overconfidence**
* Humans who want **better questions before better answers**

If you already know the cause and just want to fix it, this is not the tool.

---

## Why Monolithic?

Doctor is intentionally a **single skill** with an internal protocol.

This avoids:

* brittle cross-skill orchestration
* loss of context mid-investigation
* agents skipping steps

Internally, the protocol is still modular. Externally, invocation stays simple.

---

## # TLDR

Doctor is a diagnostic skill that treats code failures like medical cases:

* listen to symptoms
* triage possible causes
* examine evidence
* diagnose carefully
* propose treatment without acting

It exists to stop you and your agents from fixing the wrong thing for the wrong reason.
