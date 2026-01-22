# Step 3 — Design Reasoning Schemas as Static Assets

Using the judgment items from Step 2, design **strict schemas** that constrain reasoning.

These schemas exist to:

* reduce entropy
* make decisions auditable
* prevent blind inference

## Required schema types

* **Intent schema**
  What the agent believes it is being asked to do

* **Execution plan schema**
  Derived parameters, scope, and intended actions

* **Result / receipt schema**
  What was actually executed and observed

## Schema Constraints

* Schemas define **shape**, not logic
* No defaults that hide uncertainty
* Absence must be representable as data
* Schemas must be **host-agnostic**

  * no MCP assumptions
  * no IDE assumptions
  * no implicit environment or runtime coupling

Agents must never reason without a declared schema.
