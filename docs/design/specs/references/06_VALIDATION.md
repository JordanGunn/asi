# Validation Guidelines

- [ ] **Naming**: follows `<NN>_<NAME>.md` pattern
- [ ] **Frontmatter**:
  - [ ] Has required description field
  - [ ] Has required index field
- [ ] **Bodies**: Small and focused; a short length (for example: under ~100 lines) is a useful heuristic.
- [ ] Canonical file structure:
  - [ ] 01_SUMMARY.md
  - [ ] 02_INTENT.md
  - [ ] 03_POLICIES.md
  - [ ] 04_PROCEDURE.md
- [ ] Optional routing:
  - [ ] 00_ROUTER.md exists only when routing is required and declares which references to load.
- [ ] **Routing observability**: routes and preconditions make it easy to report effective scope, what was read, and precondition validation status.
