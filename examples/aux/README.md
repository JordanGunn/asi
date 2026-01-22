# AUx

[![ASI Aligned](https://img.shields.io/badge/ASI-Aligned-blue)](https://github.com/JordanGunn/asi)

**A**gentic **U**ni**x**
Nothing more. Nothing less.

> *If you are looking for ransom, I can tell you I don't have money.*
> *But what I do have is a very particular set of skills,*
> *skills I have acquired over a very long career.*

---

`aux` is a collection of **atomic agent skills** that wrap classic Unix read-only commands
(`glob`, `grep`, `regex`) with a thin agentic layer.

The tools already exist.  
The power comes from letting agents do what they're good at—**parameter selection**—while
keeping execution **fully deterministic, inspectable, and replayable**.

---

## What problem this solves

Classic Unix tools are:

- extremely powerful
- extremely reliable
- extremely unfriendly at scale

Humans are bad at:

- choosing exhaustive search terms
- anticipating edge cases
- writing correct regexes under time pressure
- scaling these operations across large trees

Agents are *excellent* at those things, but unreliable if given too much authority.

`aux` bridges that gap.

---

## What aux is

- A **facade layer** over existing Unix commands
- Each skill maps 1:1 to a familiar verb:
  - `/glob` → `fd` → file enumeration
  - `/grep` → `rg` → text search
  - `/re` → `re` → structured pattern matching
- Natural language is used **only** to express intent
- Agents generate **parameters**, not actions
- Scripts perform **all execution**

---

## What aux is not

- Not a monolithic "search tool"
- Not a prompt framework
- Not RAG
- Not embeddings
- Not magic
- Not mutation (by default)

If a task can be deterministically scripted, **the agent is not allowed to do it**.

---

## Core principles (ASI-aligned)

- **Deterministic maximalism**
  - Scripts own execution
  - argv arrays, not shell strings
  - Bounded scope, time, and output

- **Subjective minimalism**
  - Agents select parameters only where humans fail
  - No interpretation unless explicitly requested

- **Reason-after-reduction**
  - Shrink the surface *first*
  - Reason on results, not the filesystem

- **Replayability**
  - Every run produces artifacts
  - No silent overwrites
  - Explicit lifecycle controls

---

## Skill model

Each skill is **fully independent** and self-contained:

```text
aux/
  grep/
  glob/
  regex/
```

Each skill owns:

- its schemas
- its scripts
- its artifacts
- its lifecycle

They share **conventions**, not shared code.

---

## Mental model

Think of `aux` like an **auxiliary cable** (RIP):

- old
- universal
- boring
- reliable
- does exactly one thing well

You already know when you want to `grep`.
Now you don't have to guess *how*.

---

## TLDR

`aux` makes classic Unix commands **agent-operable**  
without sacrificing determinism, safety, or trust.
