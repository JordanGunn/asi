# 11. Judgment-Gated Skill Interfaces

**A skill exists to exercise judgment at a deterministic boundary.**

Capabilities that admit exactly one correct outcome for a given input must not be exposed as skills. They belong to deterministic scripts or internal mechanisms.

A skill interface is justified only when:

* input requires **entropy control** before execution, or
* output requires **judgment** to decide relevance, framing, or next action.

> Skills do not wrap mechanics.
> Skills govern **choice**.

## Operational Corollaries

1. **Pure determinism is not a skill**
   * If the agent should *never* make a decision, do not expose it.

2. **Skills sit at entropy boundaries**
   * Before determinism: constrain interpretation.
   * After determinism: constrain judgment.

3. **Judgment must be auditable**
   * Skills must expose *why* a choice was made, not just *what* was done.

4. **Scripts define reality**
   * Skills decide what to do *about* that reality.

---

## Litmus Test

Ask:

> *“Given the same inputs, could two reasonable agents make different but valid decisions here?”*

* **No** → script
* **Yes** → skill
