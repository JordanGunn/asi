# Merge Pipeline

Reassemble chunks into a single document with quality checks.

## Triggers

- When user wants to merge edited chunks
- When user is done working with chunked documents

## Steps

1. **CLI lint** — `./skill.sh lint <chunk_dir>` (pre-merge)
2. **md-merge** — Reassemble chunks
3. **CLI lint** — `./skill.sh lint <merged_file>` (post-merge)
4. **md-review** — Quality assessment

## Skills

1. md-merge
2. md-review
