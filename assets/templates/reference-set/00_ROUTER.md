# 00_ROUTER.md Template

---
description: Conditional dispatch for reference loading.
index:
  - Preconditions
  - Routes
  - Agent Contract
---

## Preconditions

### Execute

List deterministic, read-only checks that drive route selection.

```text
1. scripts/validate.sh --check prerequisites
2. scripts/validate.sh --check artifacts
```

### Check

List subjective checks that interpret explicit user intent. Keep these narrow and non-automated.

- If the user explicitly requests “start fresh”, ignore existing artifacts.

## Routes

First matching route wins. `default` should exist.

1. ready
2. in-progress
3. default

### ready

Resume after the skill’s primary artifact(s) already exist.

**When:**

- A deterministic precondition check indicates completion.
- Required artifacts exist.

**Read:**

1. 01_SUMMARY.md

**Ignore:**

1. 02_CONTRACTS.md
2. 03_TRIGGERS.md
3. 04_NEVER.md
4. 05_ALWAYS.md
5. 06_PROCEDURE.md
6. 07_FAILURES.md

#### Goto

06_PROCEDURE.md#resume

### in-progress

Resume mid-work when a session artifact exists.

**When:**

- A deterministic precondition check indicates an active session.

**Read:**

1. 01_SUMMARY.md
2. 02_CONTRACTS.md
3. 04_NEVER.md
4. 05_ALWAYS.md
5. 06_PROCEDURE.md

**Ignore:**

1. 03_TRIGGERS.md

#### Goto

06_PROCEDURE.md#resume

### default

Fresh invocation. Load all references in order.

**When:**

- No other route matches.

**Read:**

1. 01_SUMMARY.md
2. 02_CONTRACTS.md
3. 03_TRIGGERS.md
4. 04_NEVER.md
5. 05_ALWAYS.md
6. 06_PROCEDURE.md
7. 07_FAILURES.md

**Ignore:**

(none)

## Agent Contract

1. Read `00_ROUTER.md` first.
2. Execute all precondition scripts.
3. Evaluate precondition checks.
4. Match the first applicable route (top-to-bottom).
5. Load only files in the route’s **Read** list.
6. If **Goto** is specified, navigate to that anchor after loading.
7. Skip files in **Ignore** unless explicitly needed later.

## Determinism guidance

- Prefer route selection driven by deterministic **Execute** checks (exit codes and explicit file existence checks).
- If subjective checks are required, keep them limited to explicit user intent (not scope expansion).

## Observability guidance

Routing should make it easy to report:

- effective scope: which route matched and which reference files were in-bounds
- what was read: router, executed checks, and loaded references
- what was written or changed: typically nothing (routing should be read-only)
- validation status: precondition check pass/fail and any declared validations
