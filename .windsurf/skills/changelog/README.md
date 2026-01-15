# changelog

## What problem this solves

Changelogs are high‑signal, low‑maintenance artifacts—when done correctly. In practice, they often drift, duplicate entries, or get ignored entirely. This skillset exists to make **maintaining a useful `CHANGELOG.md` the path of least resistance**, without turning it into an automatic commit dump or a noisy ritual.

The goal is not to *generate* release notes, but to **curate human‑readable change history** with strong guardrails, minimal friction, and deterministic behavior.

---

## Design principles

* **Determinism first**
  * File discovery via git + filesystem rules
  * Text edits are explicit, repeatable transformations

* **Chronological awareness**
  * Prevents duplicate or pointless updates
  * Knows when nothing materially changed

* **Assistive, not automatic**
  * Git history can suggest context, never replace judgment

* **Progressive disclosure**
  * Skills stay thin; guidance lives in references

* **Spec‑aligned, not spec‑bound**
  * Based on *Keep a Changelog*, trimmed to what actually matters

---

## Mental model

Think of the changelog as a **curated event log**, not a mirror of git history.

* Git tells you *what happened*
* The changelog explains *why it matters*

This skillset enforces that distinction by:

* writing only to `[Unreleased]` until a release is cut
* grouping changes by intent (Added, Changed, Fixed, etc.)
* refusing to spam duplicate or zero‑signal entries

---

## How it works

The skillset is composed of small, focused skills that can be run independently or as pipelines:

* **`changelog-init`**
  * Creates a canonical `CHANGELOG.md`
  * Enforces structure and headings

* **`changelog-update`**
  * Adds entries to `[Unreleased]`
  * Deduplicates intelligently
  * Respects chronological relevance

* **`changelog-release`**
  * Converts `[Unreleased]` into a versioned release
  * Resets `[Unreleased]` cleanly
  
* **`changelog-verify`**
  * Validates structure, ordering, and hygiene
  * Ideal for pre‑merge or pre‑release checks

Each skill relies on deterministic shell or PowerShell scripts and lightweight agent judgment only where unavoidable.

---

## What this deliberately does *not* do

* ❌ Auto‑generate changelogs from commit history
* ❌ Infer meaning from vague commits
* ❌ Rewrite historical releases
* ❌ Enforce a specific versioning scheme

If you want automatic release notes, this is not that tool.

---

## Reference material

This skillset is informed by *Keep a Changelog 1.1.0*, but ships with:

* Chunked, trimmed reference docs
* Only core rules and workflows
* A version check that **warns** (never blocks) if upstream guidance changes

This keeps the runtime experience fast and avoids repeatedly ingesting a massive document.

---

## Constraints & assumptions

* Git repository present
* A single canonical `CHANGELOG.md`
* Human intent supplied by the user or conversation context
* Network access is optional (only used for spec freshness warnings)

---

## Intended audience

* Repositories that care about readable history
* Teams tired of broken or ignored changelogs
* Solo developers who want discipline without ceremony
* Agent‑assisted workflows that need guardrails, not guesswork

---

## TLDR

A small, deterministic skillset that makes maintaining a clean, human‑first changelog easy—without automating away judgment or flooding history with noise.
