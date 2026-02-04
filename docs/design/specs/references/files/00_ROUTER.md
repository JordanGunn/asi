# 00_ROUTER.md — Optional routing for skill references

**Purpose**:

- Optional first file read when routing is required
- Provides deterministic decision logic for which references to load
- Minimizes token consumption by skipping irrelevant sections
- Enables idempotent skills to short-circuit on re-invocation

---

## Structure

A ROUTER file consists of two sections: **Preconditions** and **Routes**.

---

## Preconditions

### Execute

Ordered list of deterministic script executions. Prioritize these over subjective checks.

```text
1. scripts/validate.sh --check session
2. scripts/validate.sh --check artifacts
```

**Constraints:**

- Scripts should be read-only.
- Scripts should complete in <500ms.
- Exit 0 = condition met, non-zero = condition not met
- The agent should run all checks before evaluating routes.

### Check

Agent instructions for subjective interpretation.

- Prefer deterministic script checks over subjective checks when possible.
- Additional subjective decision making allowed
- Example: "If user explicitly requested full initialization, treat as fresh start"

---

## Routes

Ordered list of route names. First matching route wins.

1. `<route-1>`
2. `<route-2>`
3. `default` (required)

---

## Route Definition

Each route is defined as a subsection with the following structure:

### `<Name>`

Brief description of when this route applies.

**When:**

Descriptive triggers — conditions that activate this route.

**Read:**

Ordered list of reference file names to load.

**Ignore:**

Ordered list of reference file names to skip entirely.

#### Goto

H2 anchor in target file to jump to (optional). Defaults to file title (read from top).

---

## Example: Idempotent skill (doctor)

```markdown
 # Router

---

## Preconditions

### Execute

1. scripts/validate.sh --check session
2. scripts/validate.sh --check treatment

### Check

- If user explicitly requests "start fresh", ignore existing artifacts.

---

## Routes

1. treatment-complete
2. session-active
3. default

---

### treatment-complete

Resume after treatment has been written.

**When:**

- `validate --check treatment` exits 0
- `.doctor/treatment.md` exists

**Read:**

1. 01_SUMMARY.md

**Ignore:**

1. 02_INTENT.md
2. 03_POLICIES.md
3. 04_PROCEDURE.md

#### Goto

04_PROCEDURE.md#verify-treatment

---

### session-active

Resume mid-session diagnostic work.

**When:**

- `validate --check session` exits 0
- `.doctor/session.yaml` exists

**Read:**

1. 01_SUMMARY.md
2. 02_INTENT.md
3. 03_POLICIES.md
4. 04_PROCEDURE.md

**Ignore:**

1. 02_INTENT.md
2. 03_POLICIES.md

#### Goto

04_PROCEDURE.md#resume-session

---

### default

Fresh invocation — read all references in order.

**When:**

- No other route matches

**Read:**

1. 01_SUMMARY.md
2. 02_INTENT.md
3. 03_POLICIES.md
4. 04_PROCEDURE.md

**Ignore:**

(none)
```

---

## Agent Contract

1. Read `00_ROUTER.md` first when routing is required
2. Execute all precondition scripts
3. Evaluate precondition checks
4. Match first applicable route (top-to-bottom)
5. Load only files in route's **Read** list
6. If **Goto** specified, navigate to that anchor after loading
7. Skip files in **Ignore** list unless explicitly needed later

## Determinism guidance

- Route selection should be driven primarily by deterministic checks in **Preconditions → Execute** (exit codes and explicit file existence checks) rather than by reading additional reference content.
- If subjective checks are required, they should be limited to interpreting explicit user intent (not expanding scope).

## Observability guidance

The router is a scope-control tool. It should make it easy to report, at minimum:

- **effective scope:** which route matched, and which reference files were treated as in-bounds
- **what was read:** the router itself, executed precondition checks, and the reference files loaded for the route
- **what was written or changed:** typically “nothing” during routing (routing should be read-only)
- **validation status:** whether precondition checks passed/failed, and whether any declared validations were satisfied

---

## Validation

- `00_ROUTER.md` is optional and only required when routing is necessary.
- The router should define at least the `default` route.
- All files referenced in routes should exist in `references/`.
- **Goto** anchors should match H2 headers in the target file (when an index is maintained).
- Scripts referenced in **Execute** should exist and be read-only.
