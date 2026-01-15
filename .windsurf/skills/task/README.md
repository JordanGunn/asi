# task

`task` is **AI-assisted task discipline**.

It does not replace execution.
It makes bounded, auditable work easier to create, select, track, and close.

---

## The problem

Agents can move fast, but task state can drift when it is not captured explicitly.

Common failure modes:

* Starting work without a clearly bounded scope
* Forgetting decisions made earlier in the session
* Losing the “current task” amidst context switching
* Continuing work on stale intent after requirements change

Durable task artifacts help — but only if:

* tasks are written down as the source of truth
* intent changes are detectable
* staleness is surfaced explicitly
* closing a task is a deliberate action

---

## What task is

`task` is an orchestrator skill for the `task` skillset.

It manages bounded work units with single-file tasks stored in `.tasks/`, skepticism-aware hashing, and staleness detection.

It is a single skillset entrypoint that:

* keeps task state on disk (durable, auditable)
* supports selecting a current task (`.tasks/.active`)
* detects when intent has drifted (hash mismatch / staleness)
* encourages explicit closure with a close reason

Member skills:

* `task-create`
* `task-list`
* `task-select`
* `task-close`

To run the workflow, follow `SKILL.md` and the pipelines in `.pipelines/.INDEX.md`.

---

## What task is not

`task` is not:

* a project manager
* a ticketing system
* a replacement for implementation
* a substitute for judgment

It does not decide what matters.
It only makes task intent and freshness inspectable.

---

## How it works (conceptually)

`task` separates concerns cleanly:

* **Structure on disk**

  * tasks live in `.tasks/<id>.md`
  * a current task can be recorded in `.tasks/.active`
  * metadata supports drift/staleness detection

* **Agentic reasoning**

  * deciding what the task actually is
  * keeping scope bounded
  * validating that the active task still matches user intent
  * choosing when to close and why

---

## Mental model

Think of `task` as a *single source of truth for the current work unit*.

It turns “keep working on that” into:

* a named task artifact
* an explicit active selection
* drift detection when the premise changes
* a clear close event when the work is done

---

## Constraints (by design)

* Bounded scope
* Durable artifacts in `.tasks/`
* Skepticism-aware hashing (detect intent drift)
* Explicit staleness surfacing
* Explicit closure

If `task` ever silently rewrites intent, it is doing too much.

---

## When to use task

Use `task` when:

* you need a single bounded unit of work with explicit state
* context switching is likely
* you want drift/staleness detection over time
* you need an auditable record of what was done and why

Do not use `task` to:

* replace careful technical decisions
* justify unbounded exploration
* avoid writing down intent

---

## Why this exists

Agentic work fails most often when intent is implicit.

`task` exists to keep intent explicit and durable so it can be:

* selected consistently
* re-validated when context changes
* closed deliberately

---

## TLDR

`task` is task tracking with guardrails.

It stores tasks on disk, detects drift and staleness, and makes task state explicit, nothing more.
