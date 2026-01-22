---
description: Canonical execution path for this skill.
index:
  - Step 1: Gather intent
  - Step 2: Choose pattern
  - Step 3: Run extraction
  - Step 4: Present results
  - CLI
---

# Procedure

## Step 1: Gather intent

- Parse the user's `/re <prompt>` invocation
- Identify the target pattern type and extraction goal
- Record assumptions explicitly

## Step 2: Choose pattern

- Design the regex pattern for the target
- Choose flags (case insensitive, multiline, dotall)
- Choose capture groups for structured extraction
- Set match limits and timeout

## Step 3: Run extraction

- Validate the pattern syntax
- Execute via `scripts/skill.sh run`
- Review the echoed pattern block

## Step 4: Present results

- Show the pattern block for reproducibility
- Present matches with capture groups
- Report counts and positions
- Suggest refinements if results are unexpected

## CLI

From `aux/re/`, run:

```bash
bash scripts/skill.sh run --pattern "\\d{3}-\\d{4}" --input "Call 555-1234"
```

Or on Windows:

```powershell
pwsh scripts/skill.ps1 run --pattern "\d{3}-\d{4}" --input "Call 555-1234"
```

### Validate

Before first use, verify dependencies:

```bash
bash scripts/skill.sh validate
```

## Input Sources

The skill accepts input from:

- `--input <text>` — Direct text string
- `--file <path>` — Read from file
- `--stdin` — Read from standard input

## Output Formats

The `--format` flag controls output shape. All formats emit a `pattern_block` first.

### `auto` (default)

Selects `human` for interactive use, `jsonl` when piped.

### `human`

Plain text summary followed by matches:

```text
pattern: \d{3}-\d{4}
matches: 3

555-1234
555-5678
555-9012
```

### `jsonl`

Newline-delimited JSON for programmatic consumption:

```json
{"kind":"pattern_block","pattern_block":{...}}
{"kind":"summary","matches":3,"truncated":false}
{"kind":"match","value":"555-1234","start":5,"end":13,"groups":{}}
```

## Budget Flags

Control execution deterministically:

- `--max-matches N` — Cap total matches (default: 1000)
- `--timeout N` — Timeout in seconds (default: 30)

## Reproducibility

Every invocation emits:

- `pattern_block` — Full pattern and flags
- `query_id` — SHA256 hash of normalized parameters
