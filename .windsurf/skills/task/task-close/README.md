# task-close

Close a task by setting state to closed, recording `close_reason` and `closed_at`.

Recomputes intent hash and clears `.tasks/.active` if it pointed to this task.

## How to use

- Follow `SKILL.md`.
- Refer to the documents listed in `metadata.references`.
