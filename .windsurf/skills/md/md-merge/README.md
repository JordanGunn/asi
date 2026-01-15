Perfect — here’s a **README for the `md` skillset**, written using the **template pattern you asked me to remember** (problem-first, clear principles, mental model, constraints, audience, ending with **`# TLDR`**).
This is repo-ready and intentionally non-dramatic.

---

# md — Markdown Lifecycle Skills

## The problem

Markdown documents tend to oscillate between two bad states:

* **Monolithic**: too large to reason about, review, or evolve safely
* **Fragmented**: split apart, but hard to reassemble or validate

Agents make this worse when structure, ordering, or intent becomes implicit or inferred instead of explicit and deterministic.

The `md` skillset exists to **make markdown structure explicit, repeatable, and auditable** across its entire lifecycle.

---

## What this skillset is

`md` is a small, opinionated skillset for managing markdown documents through three distinct phases:

1. **Progressive disclosure** (split)
2. **Quality assessment** (review)
3. **Consolidation** (merge)

Each phase has:

* a single responsibility
* deterministic scripts where structure is involved
* clear guardrails for agent behavior

---

## What this skillset is not

* Not a markdown formatter
* Not a style guide
* Not a content generator
* Not an agent-driven restructuring tool

Agents **never** decide structure.
Agents **never** create or rename split files.
Agents **never** merge by intuition.

---

## The skills

### `md-split`

Splits a monolithic markdown document into ordered, numbered files for **progressive disclosure**.

* Structure is defined by `##` headings
* Filenames are deterministic (`NN_NAME.md`)
* H2 headings are promoted to H1
* Scripts create all files
* Optional `.SPLIT.json` records what happened (read-only artifact)

Use when:

* A document is too large to reason about safely
* You want agent-friendly, reviewable chunks
* You want stable diffs and explicit structure

---

### `md-review`

Provides **agent-driven quality review**, not editing.

* Always runs deterministic lint first
* Reviews structure, clarity, and flow
* Produces findings, not changes
* Separates objective issues from subjective suggestions

Use when:

* After splitting or merging
* Before finalizing a document
* You want feedback without mutation

---

### `md-merge`

Reassembles split markdown files back into a single document.

* Ordering is numeric and explicit
* H1 headings are demoted back to H2
* Content is preserved verbatim
* Scripts are the sole authority

Use when:

* Preparing a document for publishing
* Concluding a review cycle
* Returning to a single-file representation

---

## Mental model

Think of `md` as a **build pipeline for documents**:

```
SOURCE.md
   ↓
md-split   (structure becomes explicit)
   ↓
md-review  (quality gate, no mutation)
   ↓
md-merge   (structure collapses deterministically)
   ↓
FINAL.md
```

At no point does an agent:

* invent structure
* infer ordering
* silently mutate content

---

## Design principles

* **Determinism first**
  Structure is produced by scripts, not agents.

* **Separation of concerns**
  Split, review, and merge are independent and composable.

* **Progressive disclosure**
  Optimize for reasoning first, presentation second.

* **Auditability**
  Every structural change is observable and repeatable.

---

## Constraints and guarantees

* Scripts are the single source of truth for structure
* Agents operate *after* deterministic outputs exist
* Read-only artifacts (`.INDEX.md`, `.SPLIT.json`) describe state, not intent
* Round-tripping (`split → merge`) must preserve content

---

## Who this is for

* Repos with large or evolving markdown docs
* Agent-assisted documentation workflows
* Teams that care about reviewability and diffs
* Anyone tired of “AI rewrote my document” surprises

---

## # TLDR

`md` turns markdown into a **deterministic lifecycle**:

* split to reason
* review to improve
* merge to publish

Structure is scripted.
Agents review, never guess.
