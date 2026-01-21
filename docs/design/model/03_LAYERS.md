# Layer Meanings

## 1) User Intent

Natural language requests are high-entropy:

* incomplete
* ambiguous
* contextual
* prone to underspecification

This is not a reliable execution surface. It is the starting point.

---

## 2) Reasoning Contract

The Reasoning Contract exists to **bound interpretation before execution**.

It reduces input entropy into a form that deterministic mechanisms can consume without guessing.

Typical contents:

* scope declarations (what will be read, where search is allowed)
* parsed filters / selectors
* schema-shaped query plans
* explicit assumptions when unavoidable

Key property:

* It constrains *how ambiguity is resolved*.
* It does not claim truth about the world.

---

## 3) Deterministic Execution

This layer defines **mechanical truth-making**.

Outcomes here must be:

* reproducible
* auditable
* scriptable
* insensitive to agent interpretation

Typical operations:

* file discovery and ordering
* hashing and change detection
* chunking / boundary derivation
* schema validation
* emitting receipts and manifests

Key property:

* No discretion.
* No semantic interpretation.
* If two implementations disagree, at least one is wrong.

---

## 4) Judgment Contract

Once deterministic execution produces a bounded surface, the system reaches a point where **multiple valid choices** can exist.

The Judgment Contract exists to:

* constrain discretion
* keep judgment auditable
* prevent semantic authority creep

Typical contents:

* selection rules (how many results to surface, tie-breaking)
* framing rules (how to summarize without claiming completeness)
* escalation rules (when to ask a follow-up)
* recommendation rules (when to suggest refresh / next steps)

Key property:

* Judgment is allowed, but governed.
* It decides what matters *now*, not what is true.

---

## 5) Artifacts & Outcomes

This layer captures both:

* **Artifacts**: durable, inspectable records (indexes, receipts, validation reports)
* **Outcomes**: what a user consumes (surfaced results, explanations, recommendations)

Key property:

* The output is a product of:

  * a declared interpretation (Reasoning Contract),
  * mechanical truth-making (Deterministic Execution),
  * bounded discretion (Judgment Contract).
