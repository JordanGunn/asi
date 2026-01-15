# Nunchuck Prompt Skills

## Philosophy

Most prompt failures don’t come from bad models.
They come from **unclear intent**.

When people start a conversation with an AI, they usually *don’t yet know exactly what they want*. They discover it along the way—by asking questions, correcting themselves, and refining their thinking. Unfortunately, most systems treat every message as authoritative and immediately actionable, even when the human is still figuring things out.

**Nunchuck `prompt` skills exist to fix that.**

---

## What this is

Nunchuck `prompt` skills are a small, opinionated skillset designed to **separate thinking from acting**.

It provides a safe, structured way to:

* clarify what you actually mean
* refine that meaning collaboratively with an agent
* stabilize it into a single, canonical prompt
* export it for reuse **without executing**
* execute it *only when you explicitly decide to*

Nothing more.  
Nothing less.

---

## The core idea

The `prompt` skills is built on three simple principles:

### 1. Humans discover intent over time

Early instructions are often wrong, incomplete, or contradictory. That’s normal. Prompt Forge assumes this and treats early input as *signal*, not truth.

### 2. Conversation is not state

Chat history is messy, nonlinear, and full of revisions. These skills do not not rely on conversational memory. The **disk is the source of truth**, and only explicit skill invocations are allowed to change it.

### 3. Execution should be deliberate

Running a prompt is a real action with consequences. Prompt Forge makes execution explicit, intentional, and irreversible—never accidental.

---

## How it works (high level)

The set consists of **three tightly scoped skills**, each with a distinct responsibility.

### `prompt-forge`

This is where thinking happens.

* You describe what you’re trying to do.
* The agent challenges ambiguity, surfaces assumptions, and reflects your intent back to you.
* A single prompt manifest on disk is continuously refined.
* Nothing is executed.
* You can iterate as long as you need.

Think of this as **shaping intent**, not issuing commands.

---

### `prompt-compile`

This is where intent becomes portable.

* The agent reads the forged prompt manifest.
* It generates a human-readable `PROMPT.md` file.
* No execution occurs.
* The live prompt remains intact.

This exists to let you:

* review the final prompt outside the skill system
* pipe it into other tools or skills
* store or version it for later use
* share it with humans or agents safely

`prompt-compile` is explicitly **non-destructive** and **non-executing**.

---

### `prompt-exec`

This is where action happens.

* The agent reads the forged prompt *exactly as written*.
* It confirms what will be executed.
* It executes once.
* The prompt is deleted afterward.

Execution is **explicit, destructive, and final** by design.

---

## Why this is useful

These prompt skills are especially valuable when:

* you’re designing complex prompts or workflows
* the goal is still evolving
* precision matters
* you're not entirely confident in your intent
* you want to reuse a prompt without immediately running it
* you want to avoid “the model ran with the wrong idea”

It helps prevent:

* premature execution
* silent assumption drift
* overfitting to early misunderstandings
* accidental reuse of outdated intent
* coupling “saving” with “running”

---

## What this is not

The `prompt` skills are **not**:

* a prompt generator
* a task queue
* an automation engine
* a persona or roleplay system
* a replacement for judgment

It does not try to be clever.
It tries to be *safe, clear, and boring in the right places*.

---

## Mental model

A useful way to think about it:

> **Forging is preparation.
> Compiling is preservation.
> Execution is commitment.**

You can forge indefinitely.
You can compile without consequence.
You execute only when you’re sure.

---

## Design constraints (intentional)

* Only one live prompt exists at a time.
* Execution deletes the prompt.
* Compilation never mutates or deletes state.
* No state is assumed outside explicit skill calls.
* Clarification and reflection are always on.
* Nothing runs unless you say so.

These constraints are features, not limitations.

---

## Who this is for

Prompt Forge is for people who:

* think out loud
* revise their understanding mid-conversation
* care about correctness more than speed
* want AI to challenge them *before* acting
* want to reuse prompts without executing them
* prefer explicit boundaries over magic behavior

---

## TLDR

> Lazy prompt execution.

The `prompt` skills help you **figure out what you actually want**, preserve it safely, and execute it only when you mean to.
