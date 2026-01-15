# Reference File Naming

## Pattern

Reference files should be named in the form:

```text
<NN>_<NAME>.md
```

Where:

* `<NN>` is a two-digit, zero-padded ordinal (`00`, `01`, `02`, …)
* `<NAME>` is descriptive (uppercase is a common convention, but not required)

## Example

```text
00_INSTRUCTIONS.md
```

## Rationale

Provides an implicit signal to the agent about the order in which content should be read.

* Ordering is determined by filename, not content
