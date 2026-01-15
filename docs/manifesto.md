# The ASI Manifesto

> Why Agent Skill Interface (ASI) Exists

## We Didn’t Have a Tooling Problem

We had an expectation problem.

The modern agent ecosystem is full of powerful tools.

MCP servers expose file systems, memory stores, APIs, databases.
Agent skills let us define arbitrarily complex capabilities.
Everything looks capable. Everything looks ready.

And yet, again and again, people say:

> “This MCP server sucks.”
> “These tools don’t work.”
> “It looks great on paper, but nothing happens.”

This is not because MCP servers are poorly built.
It is not because skills are insufficiently clever.
It is not because the community lacks effort or intelligence.

It’s because **capability has been mistaken for behavior**.

## The Illusion of Passivity

Most users—*including experienced builders*—implicitly assume that:

- exposed tools will be used
- available state implies awareness
- memory implies recall
- skills imply execution
- good prompts imply correct behavior

None of these assumptions are true.

Agentic systems are **not passive**.
They do nothing unless invoked—explicitly, correctly, and in the right order.

An MCP server does not “work” in the background.
A skill does not “kick in” because it seems relevant.
A tool does not “help” unless it is deliberately used.

The system is silent by default.

And silence is often misdiagnosed as failure.

## Why Forking Didn’t Fix It

When MCP servers fail expectations, the instinctive response is to patch:

- add prompt injection to improve reasoning
- add memory to improve awareness
- add tools to improve coverage
- add background logic to “help”

These forks are well-intentioned—and almost always ineffective.

Because **no amount of reasoning fixes a system that was never correctly invoked**.

There is no perfect balance of prompts, tools, and resources that turns capability into intent.
If such a balance existed, someone would have found it by now.

The problem was never *inside* the MCP server.

## Skills Didn’t Magically Solve This Either

The Agent Skills specification was a major step forward.

It acknowledged something important:

> tools alone are not enough—agents need structured entry points.

But “skills” introduced a new abstraction with an old risk.

The word *skill* is accurate—and dangerously vague.

A skill can mean:

- a deterministic operation
- a suggestion
- a workflow
- a heuristic
- a guess wrapped in natural language

When natural language becomes a contract for machine execution,
**scope becomes instinctive instead of explicit**.

Why glob files when you can say:

> “Check all the files with postgres in them”?

Why constrain the surface when the agent *seems* smart enough?

Because instinct is not determinism.
And instinct is not auditable.

## The Core Truth

**Agentic systems are black boxes—even to the people who build them.**

This is not a moral failure.
It is a structural reality.

When reasoning, tools, memory, and execution are all blended together:

- no one knows what ran
- no one knows why
- no one knows what changed
- no one knows what was even considered

ASI exists because this is not acceptable for real work.

## What ASI Is

The **Agent Skill Interface (ASI)** is not a new protocol.
It does not replace MCP.
It does not redesign skills.

ASI is a **behavioral contract**.

It exists to define:

- when reasoning is allowed
- what may be reasoned over
- how scope is constructed
- how state is written
- how failures surface
- what *must never happen silently*

ASI does not make agents smarter.
It makes systems **trustworthy**.

## The Philosophy

### 1. Determinism Before Reasoning

Agents may not reason over undefined reality.

First, the surface is reduced—explicitly and measurably.
Only then may interpretation occur.
Mutation is optional, constrained, and visible.

### 2. Skills Are Policy, Not Convenience

A skill is not “something the agent can do.”
A skill is **something the agent is allowed to do**, under rules.

### 3. Capability Does Not Imply Behavior

Tools expose *what is possible*.
ASI defines *what is valid*.

### 4. Passive Means Passive

Systems may observe and report.
They may not act without intent.

No auto-repair.
No background mutation.
No silent “help.”

### 5. Failure Is Better Than Ambiguity

If guarantees cannot be upheld, the system must stop.

Partial success is corruption with better PR.

## Why This Matters

Without a governing layer:

- users blame tools for not thinking
- builders add heuristics instead of structure
- systems rot quietly
- trust erodes
- automation becomes folklore

With ASI:

- expectations are explicit
- invocation is intentional
- behavior is reproducible
- state is auditable
- tools are judged fairly

MCP servers stop being blamed for things they were never designed to do.
Skills stop pretending to be magic.

## What ASI Refuses to Promise

ASI does **not** promise:

- that agents will “figure it out”
- that tools will be used automatically
- that memory implies understanding
- that capability implies correctness

ASI promises something harder—and more valuable:

> **If something happens, you will know why.**
> **If nothing happens, that will also be correct.**

## Why This Manifesto Exists

This was written because too many systems *look* powerful while behaving unpredictably.
Because too many builders blame themselves for structural problems.
Because too many users are taught to expect magic from silence.

ASI exists to replace illusion with intention.

## Closing Principle

> **Agents should be powerful thinkers, not powerful actors.**
> **ASI exists to make that distinction enforceable.**

