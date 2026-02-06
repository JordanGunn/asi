# What Should (and Shouldn’t) Be a Skill?

## Litmus test

Ask:

> “Given the same inputs, could two reasonable agents make different but valid choices?”

- **No** → script/tool
- **Yes** → skill (govern the choice and make it auditable)

## Examples that *should* be skills

- “Select the right scope + filters, then run a deterministic analysis”
- “Decide which findings matter to a scientist, then generate a report”

## Examples that should *not* be skills

- “List files in a directory” (pure determinism)
- “Convert JSON → CSV” (pure determinism)

<!--
Speaker notes:
- Principle: `docs/design/principles/11_INTERFACES.md`
-->
