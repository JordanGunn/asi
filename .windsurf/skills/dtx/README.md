# dtx,  Disk Context

## What this is

**dtx** is a disk-backed **context contract**.

It provides a visible, auditable, and rebuildable working context that governs what an agent is allowed to rely on while performing tasks.

This context lives on disk, not in the model’s hidden state.

---

## What problem this solves

Agent systems accumulate context implicitly:

* through long conversations
* through exploration and backtracking
* through assumptions that quietly persist
* through summaries that overwrite nuance

This leads to:

* drift
* stale assumptions
* invisible constraints
* overconfidence based on outdated premises

Users cannot inspect or correct an agent’s internal context window.

**dtx exists to fix that asymmetry.**

---

## Core idea

You cannot control an agent’s memory.
You *can* control what the agent is allowed to reason from.

dtx makes that explicit.

---

## The contract model

dtx defines a **canonical working context** on disk that the agent must treat as authoritative.

This contract captures:

* current intent
* decisions considered final
* active constraints
* facts vs assumptions (explicitly separated)
* open questions
* evidence anchors into the system under analysis
* freshness and integrity signals

If it is not represented in the disk context, it is not admissible by default.

---

## Authority rules

1. The disk context is the source of truth.
2. The agent must not resurrect or rely on prior exploration that is not represented in the contract.
3. When the contract is stale or inconsistent with reality, the agent must surface that explicitly.
4. Updates to context must be intentional, inspectable, and grounded in evidence.

---

## Determinism vs judgment

dtx is deliberately split along a hard boundary:

### Deterministic (tool-enabled)

* change detection against the underlying system (e.g. version control state)
* hashing and integrity checks
* time awareness and staleness detection
* mechanical discovery and search
* quantitative bounds and archival

These define **objective reality**.

### Subjective (agent reasoning)

* interpreting evidence
* deciding what matters now
* classifying facts vs assumptions
* phrasing and summarization for humans

Judgment is allowed,  but it must be grounded in deterministic signals.

---

## What dtx is not

dtx is **not**:

* a memory system
* a summarizer
* a database
* a replacement for documentation
* a way to “erase” what a model has seen
* an autonomous reasoning engine

It does not promise perfect recall or perfect forgetting.

It promises **governance**.

---

## How you interact with it (conceptually)

dtx exposes a small set of explicit actions that change meaning:

* inspect what the agent currently relies on
* gather deterministic evidence
* retire premises that are no longer valid
* intentionally update the working context
* checkpoint and restore prior states

Everything else: validation, freshness checks, archival, happens automatically and is surfaced only when it matters.

---

## Why disk matters

The disk is:

* inspectable
* versionable
* hashable
* compressible
* auditable
* external to the model

By anchoring context to disk, dtx makes agent behavior:

* reviewable
* correctable
* reproducible
* safer over long-running or complex work

---

## Design principles

* **Visibility over cleverness**
* **Contracts over vibes**
* **Determinism before interpretation**
* **Explicit change over silent drift**
* **Refusal over guessing**

If something cannot be defended, it should not be assumed.

---

## TLDR

**dtx is a visible, disk-backed contract that governs what an agent may rely on,  and keeps that contract honest over time.**
