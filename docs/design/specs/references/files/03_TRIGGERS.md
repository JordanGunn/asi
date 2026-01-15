# 03_TRIGGERS.md — Invocation criteria (not automation)

**Purpose**:

* Control *when* it is appropriate to invoke the skill
* Prevent inappropriate invocation or persistence

**Contains**:

* Positive criteria (signals to invoke)
* Negative criteria (signals to avoid or exit)
* Explicit “do not infer” cases

**Example sections**:

* ✅ Invoke when…
* ❌ Do not invoke when…
* 🛑 Stop/exit immediately if…

**Constraints**:

* No instructions on *how* to act
* No procedures
* Only decision signals

## Important

“Triggers” here means *invocation criteria*, not automatic behavior.

- It does not imply background execution.
- It does not imply auto-invocation “when relevant”.
- Invocation still requires explicit user intent and an explicit decision to run the skill.

> This file is a guardrail against overuse and accidental “smart default” behavior.
