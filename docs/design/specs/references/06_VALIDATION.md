# Validation Guidelines

- [ ] **Naming**: follows `<NN>_<NAME>.md` pattern
- [ ] **Frontmatter**:
  - [ ] Has required description field
  - [ ] Has required index field
- [ ] **Bodies**: Small and focused; a short length (for example: under ~100 lines) is a useful heuristic.
- [ ] Canonical file structure:
  - [ ] 00_ROUTER.md
  - [ ] 01_SUMMARY.md
  - [ ] 02_TRIGGERS.md
  - [ ] 03_NEVER.md
  - [ ] 04_ALWAYS.md
  - [ ] 05_PROCEDURE.md
  - [ ] 06_FAILURES.md
- [ ] **Routing observability**: routes and preconditions make it easy to report effective scope, what was read, and precondition validation status.
