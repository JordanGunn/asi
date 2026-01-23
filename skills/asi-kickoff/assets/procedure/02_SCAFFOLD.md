# Step 0 — Scaffold Repository Structure

The first action is to scaffold the **canonical directory structure**.

This structure is authoritative and must not drift.

**Important**: Scaffolding during kickoff produces a `SCAFFOLD.json` artifact only. Actual directory creation occurs during `asi-exec`.

## Deciding: Single vs Grouped

Before scaffolding, the agent must decide whether the skill is single or grouped.

This decision requires a reasoning schema (`skill_type_v1.schema.json`) and produces an artifact (`SKILL_TYPE.json`).

### When to use Single Skill

* One cohesive capability
* One natural language interface
* No sub-commands or verbs
* **Uniform epistemic profile** — all operations require similar reasoning depth

**Example**: A `summarize` skill that takes text and produces a summary. One input, one output, one reasoning contract. No sub-commands with distinct profiles.

### When to use Grouped Skills

* Multiple related commands sharing a prefix
* Each command has distinct behavior requiring its own SKILL.md
* **Commands have distinct epistemic profiles** — some require agent reasoning, others are deterministic

**Example**: A `report` skill group:

| Sub-skill | Epistemic Profile |
| --------- | ----------------- |
| `report-plan` | **Judgment-heavy** — agent interprets user intent, selects data sources, constructs query plan |
| `report-fetch` | **Deterministic** — executes query plan, retrieves data, no reasoning |
| `report-render` | **Deterministic** — transforms data to output format per template |

The entropy control boundary is clear: only `report-plan` requires agent reasoning. Grouping makes this explicit and auditable.

## Single Skill Repository

```text
<skill-name>/
  README.md            # User-facing overview
  bootstrap.sh         # Dependency bootstrap (explicit consent required)
  bootstrap.ps1
  <skill-name>/        # Canonical skill root
    SKILL.md           # Must conform to ASI SKILL.md specification
    assets/            # Owned by this skill exclusively
    scripts/
    references/        # Canonical reference files only
```

## Grouped Skill Repository

```text
<skill-prefix>/
  README.md
  bootstrap.sh
  bootstrap.ps1
  <skill-prefix>-<verb-1>/
    SKILL.md
    assets/            # Owned by this sub-skill exclusively
    scripts/
    references/
  <skill-prefix>-<verb-2>/
    SKILL.md
    assets/            # Owned by this sub-skill exclusively
    scripts/
    references/
  ...
```

### Grouped Skill Conventions

* **Prefix**: Common identifier (e.g., `loop`, `asi`)
* **Verb**: Action performed (e.g., `forge`, `step`, `exec`)
* **Full name**: `<prefix>-<verb>` (e.g., `loop-forge`, `loop-step`)
* **No shared assets**: Each sub-skill owns its assets exclusively
* **Independent SKILL.md**: Each sub-skill has its own natural language interface

### Script vs Skill Interface

| Concept | Location | Purpose |
| ------- | -------- | ------- |
| Script | `scripts/*.sh` | Deterministic entrypoint — file I/O, state machine |
| Skill Interface | `SKILL.md` + `references/` | Agent instructions — when/why/how to invoke |

A script named `loop-forge.sh` is NOT the skill interface. The skill interface is `loop-forge/SKILL.md` with its references.

## Reference Files

* Reference filenames and ordering **must** follow:

```text
../asi/docs/design/specs/references/
```

* These are the **only** reference files that may exist
* Empty files are acceptable; additional files are not

## Scaffolding Artifacts

Kickoff produces these artifacts (no actual directories created):

| Artifact | Schema | Purpose |
| -------- | ------ | ------- |
| `SKILL_TYPE.json` | `skill_type_v1.schema.json` | Single or grouped decision |
| `SCAFFOLD.json` | `*_scaffold_v1.schema.json` | Directory structure to create |

`asi-plan` inspects these artifacts. `asi-exec` ingests `SCAFFOLD.json` to run scaffolding scripts.

This step establishes structural determinism before reasoning begins.
