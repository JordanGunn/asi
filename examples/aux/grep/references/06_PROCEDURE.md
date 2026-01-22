---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather intent
  - Step 2: Choose parameters
  - Step 3: Run search
  - Step 4: Present results
  - CLI
---

# Procedure

## Step 1: Gather intent

- Parse the user's `/grep <prompt>` invocation
- Identify the target concept and minimum evidence needed
- Record assumptions explicitly

## Step 2: Choose parameters

- Choose root directory (default: current workspace)
- Choose patterns (literal terms first, regex only if needed)
- Choose include globs (file types to search)
- Choose exclude globs (directories/files to skip)
- Choose match mode (`fixed` or `regex`)
- Choose case behavior (`sensitive`, `insensitive`, `smart`)
- Set budget caps

## Step 3: Run search

- Validate the plan against the schema
- Execute via `scripts/skill.sh run`
- Review the echoed parameter block

## Step 4: Present results

- Show the parameter block for reproducibility
- Present matches with file paths and line numbers
- Report counts and distributions
- Suggest refinements if results are too broad or empty

## CLI

From `aux/grep/`, run:

```bash
bash scripts/skill.sh run --root . --pattern "term" --mode fixed --case smart
```

Or on Windows:

```powershell
pwsh scripts/skill.ps1 run --root . --pattern "term" --mode fixed --case smart
```

### Validate

Before first use, verify dependencies:

```bash
bash scripts/skill.sh validate
```

## Output Formats

The `--format` flag controls output shape. All formats emit a `param_block` first.

### `auto` (default)

Selects `human` for interactive use, `jsonl` when piped.

### `human`

Plain text summary followed by match lines:

```text
files: 12
matches: 47
path/to/file.py:10:matched line content
```

### `jsonl`

Newline-delimited JSON for programmatic consumption:

```json
{"kind":"param_block","param_block":{...}}
{"kind":"summary","files":12,"matches":47,"truncated":false}
{"kind":"match","path":"path/to/file.py","line":10,"content":"matched line content"}
```

## Budget Flags

Control output size deterministically:

- `--max-lines N` — Cap total output lines (default: 500)
- `--max-files N` — Stop after N files with matches
- `--max-matches N` — Stop after N total match lines

Caps are applied **after sorting**, so truncated output remains stable.

## Reproducibility

Every invocation emits:

- `param_block` — Full parameter set including `argv`
- `query_id` — SHA256 hash of normalized parameters
