# 🍇 grape

`grape` is **AI-enabled grep**.

It does not replace grep.
It makes grep usable when humans (and agents) are bad at choosing parameters.

---

## The problem

Agents are very good at reasoning and very bad at *search discipline*.

Common failure modes:

* Reading files too early
* Anchoring on the first plausible directory
* Missing infrastructure, config, or cross-cutting code
* Wasting tokens reading what should have been discovered by search

Grep already solves most of this — but only if:

* the right roots are chosen
* the right patterns are included or excluded
* the right terms are searched
* the right breadth is applied

Those choices are subjective, error-prone, and rarely audited.

---

## What grape is

`grape` is **grep with AI-chosen parameters**.

It is a single skill that:

* translates imprecise intent into explicit search parameters
* executes a deterministic, auditable search over disk
* returns surface-level evidence suitable for discovery

It exists to answer:

* *Where might this live?*
* *What parts of the repo are involved?*
* *Does this concept appear at all?*

---

## What grape is not

`grape` is not:

* a semantic search engine
* an index or database
* a code reader
* a replacement for reasoning

It does not explain behavior or architecture.
It only reveals **where to look next**.

---

## How it works (conceptually)

`grape` separates concerns cleanly:

* **Deterministic execution**

  * portable grep-style search
  * stable output
  * auditable parameters
  * no hidden state

* **Agentic reasoning**

  * interpreting user intent
  * choosing roots, globs, and terms
  * expanding vocabulary carefully
  * widening or narrowing deliberately

The intelligence is in **parameter choice**, not execution.

---

## Mental model

Think of `grape` as a *surface scan*.

It gives you the shape of the codebase before you dig:

* dominant file types
* likely domains
* unexpected modules
* ignored infrastructure

You run `grape` **before** reading files, not after.

---

## Constraints (by design)

* One skill
* One responsibility
* Deterministic behavior
* Explicit uncertainty
* No silent inference

If `grape` ever feels clever, it is doing too much.

---

## When to use grape

Use `grape` when:

* the user asks “where is X implemented?”
* terminology may not match code
* the repo is unfamiliar
* you feel tempted to start opening files

Do not use `grape` to:

* explain logic
* understand behavior
* replace careful reading

---

## Why this exists

Grep has always been enough.

What changed is that we now have agents capable of:

* interpreting vague intent
* reasoning about vocabulary
* choosing search boundaries responsibly

`grape` simply connects those capabilities to a tool that already works.

---

## TLDR

`grape` is grep with judgment.

It forces surface discovery before depth,
keeps search deterministic and auditable,
and lets AI choose parameters humans are bad at choosing —
nothing more.
