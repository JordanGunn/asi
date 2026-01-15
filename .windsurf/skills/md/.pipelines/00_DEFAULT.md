# Default Pipeline

Split a markdown file and review the chunks.

## Triggers

- When user invokes `/md` without specifying member skill
- When user wants to split a large document

## Steps

1. **md-split** — Split by H2 headings
2. **CLI lint** — `./skill.sh lint <output_dir>`
3. **md-review** — Quality assessment

## Skills

1. md-split
2. md-review
