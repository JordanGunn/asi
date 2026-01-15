# sniff

## What problem this solves

Code smells are widely documented, named, and understood — yet in practice they’re treated informally, rediscovered repeatedly, or lost as code moves.

`sniff` exists to **detect, record, and track recognized code smells** in a repository without requiring:

* deep semantic understanding,
* manual agentic code reading,
* databases, services, or background processes.

It turns smells into **stable, locatable artifacts** that survive refactors, line shifts, and formatting changes.

---

## What `sniff` is

`sniff` is a **deterministic smell detection and tracking skillset**.

It:

* detects **canonical code smells** (by name, from recognized sources),
* stores each finding with a **lightweight content anchor**,
* lets you **list, validate, and re-locate** smells as code changes over time.

It does **not**:

* judge architectural intent,
* auto-refactor code,
* generate plans or fixes,
* invent new smell taxonomies.

---

## Design principles

### 1. Smell names are the identity

Each finding is keyed by a **canonical smell name** (e.g. *Long Method*, *Feature Envy*), not by tool, heuristic, or detector.

Grouping (Bloaters, Couplers, etc.) is metadata — not identity.

### 2. Determinism over intelligence

`sniff` prefers:

* grep-style heuristics,
* file + line ranges,
* content hashing,
  over probabilistic or semantic analysis.

False positives are acceptable. Silent misses are not.

### 3. Anchors, not assumptions

Line numbers drift. Files move. Formatting changes.

Each smell is stored with a **small content anchor + hash**, allowing the smell to be re-found without rereading the whole codebase.

### 4. No databases, no services

All state lives in the repo under `.sniff/`.

Everything is:

* append-only,
* diffable,
* regenerable.

---

## Mental model

Think of `sniff` as a **ledger of technical debt signals**.

* Detectors *add entries*.
* The locator *keeps them pointing at the right place*.
* Humans (or other skills) decide what to do with them later.

`sniff` does not close issues.
It ensures you don’t lose track of them.

---

## Skill layout

### Smell detectors (by group)

* `sniff-bloaters`
* `sniff-couplers`
* `sniff-abusers`
* `sniff-preventers`

Each detector:

* scans deterministically,
* emits smell findings,
* never deletes existing records.

### Locator / list

* `sniff-locate`

This skill:

* lists findings,
* validates their locations,
* re-anchors them if code shifts,
* marks them `active`, `stale`, or `missing`.

---

## Data model (high level)

All findings are stored in:

```
.sniff/findings.jsonl
```

Each record includes:

* canonical smell name
* group
* file path
* line range (fast path)
* content anchor + hash (stable identity)
* evidence + detector ID
* status (`active | stale | missing`)

No single field is trusted alone.

---

## What this deliberately avoids

* Language-specific AST frameworks
* Centralized severity scoring
* Automatic refactor suggestions
* Agent “interpretation” during detection
* Long-running caches or indexes

Those belong in *other* skills.

---

## Intended audience

`sniff` is for:

* engineers who want **repeatable visibility** into code smells,
* agent workflows that must avoid ad-hoc code reading,
* repositories where technical debt needs to be *tracked*, not just discussed.

It is **not** a teaching tool or a refactoring assistant by itself.

---

## How this fits with other skills

`sniff` is designed to compose well with:

* planning / backlog skills,
* refactoring or “doctor”-style skills,
* reporting or visualization layers.

It answers **“where are the smells, and are they still there?”**
Nothing more. Nothing less.

---

# TLDR

`sniff` is a lightweight, deterministic system for **detecting and tracking recognized code smells by name**, storing them as anchored records that survive code movement — without databases, deep analysis, or agent guesswork.
