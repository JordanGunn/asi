# Paradigms, Patterns, and Anti-Patterns

This page captures the mindset and supporting references to carry into every skill enhancement, especially the coding-focused ones that ship deterministic behavior, scripts, or UI logic.

## Target paradigms

- **Artifact-first thinking:** Every change begins with `.asi/enhance` artifacts; reviews and routing decisions should happen before content edits.
- **Deterministic flow:** Scripts, templates, and instructions should produce the same outcome every time (no ad-hoc shell commands or vague “do this manually” notes).  Use helpers like `scripts/init.sh` and `scripts/scan_skill.py` so gated steps stay reproducible.
- **Explicit gating:** Approval, plan sign-off, and validation steps are first-class citizens; no implementation occurs without the user signing off or an `asi-exec` hand-off.
- **Instrumented observability:** Record decisions, validation results, and why each chunk of work exists inside the enhancement report, changelog entry, or execution logs.
- **Reference-heavy context:** Move the explanation into `references/` files instead of bloating `SKILL.md`, and always cite where you derived a guideline.

## Resonant patterns to follow

- **Route → plan → report → implement:** After routing via `references/00_ROUTER.md`, draft the planned changes in `.asi/enhance/ENHANCEMENT_REPORT.md`, log intent in `CHANGELOG_ENTRY.md`, then implement only after approval.
- **Template-first documentation:** Keep reports, changelog entries, and instructions based on the provided templates so downstream reviewers can quickly find the data they need.
- **Elicit reliability/performance/security explicitly:** Each enhancement should call out its expected reliability, performance, and security impacts (use the proper sections in the report and checklist entries to capture them).
- **Encourage deterministic scripts:** If a task must be repeated (run a scan, generate docs, validate state), wrap it in a script stored in `scripts/` rather than instructing an agent to retype commands.
- **Use supporting references:** When the skill touches cargo workspaces, builds, or specific runtimes, consult the relevant companion skill docs (`cargo-workspace-boundaries`, `testing-matrix`, `wasm-webdev`, etc.) to avoid repeating discovery.

## Anti-patterns to avoid

- **Skipping plans:** Never jump straight to editing files before the enhancement plan lives in `.asi/enhance/ENHANCEMENT_REPORT.md` and has user approval.
- **Ignoring artifacts:** Treating `STATE.json`, `SCAN.md`, or the changelog as optional invites drift; always review them for anomalies before making choices.
- **Mixing concepts in `SKILL.md`:** Keep the manifest concise and move the “why” or supportive context into `references/` so instructions stay scannable.
- **Repetition without abstraction:** Copying the same steps into every skill instead of creating or pointing to reusable scripts defeats reliability and token efficiency.
- **Driving destructive changes without oversight:** Any script that deletes files, rewrites databases, or modifies other skills must carry a confirmation flag and be logged in `ENHANCEMENT_REPORT.md`.

## Supporting references

Treat these documents as go-to supplements when planning a coding-focused enhancement:

1. `references/00_ROUTER.md` – The master routing guide; it now directs you to this paradigms doc as part of the preconditions.
2. `references/02_CONTRACTS.md` – Invariants and cross-skill compatibility rules you must honor.
3. `references/04_NEVER.md` – Reminders of forbidden behaviors (destructive scripts, unapproved edits, etc.).
4. `references/06_PROCEDURE.md` and `references/08_CHECKLISTS.md` – The procedural steps and checklists that confirm you exercised the desired patterns.
5. `assets/templates/ENHANCEMENT_REPORT.template.md` and `assets/templates/CHANGELOG_ENTRY.template.md` – Template anchors to record intent, rating, and acceptance criteria.
6. Companion skill docs such as `cargo-workspace-boundaries`, `testing-matrix`, `wasm-webdev`, and `tokenefficient` for focused guidance on workspaces, testing selections, UI/routing behavior, or token-efficient workflows.
7. Execution logs (e.g., `execution/verification_report.json`) once they exist; preserve observability by appending entries where scripted validations or gating decisions occur.

Take a second look at this document whenever you start a new enhancement so the target paradigms remain top of mind.
