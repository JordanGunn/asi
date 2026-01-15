# Contributing

This repository is a specification project. Contributions should improve clarity, determinism, and auditability of the ASI model without introducing new concepts.

## What to contribute

Good contributions include:

- clarifications that are directly supported by existing text in `docs/` and `references/`
- stronger checklists / conformance criteria derived from existing requirements
- small examples that illustrate existing rules without expanding scope
- structural improvements (templates, deterministic checks in `scripts/`)

Changes that introduce new mechanisms, new protocols, or implied auto-action are out of scope.

## Workflow

1. Read `docs/manifesto.md` and the RFCs in `docs/spec/`.
2. Make your change minimal and focused.
3. Run `scripts/check_structure.sh` and `scripts/lint_markdown.sh`.
4. Open a pull request with:
   - what you changed
   - why it is consistent with the existing spec
   - what it improves for implementers or auditors

## Writing rules (repository-wide)

- Prefer short sections and bullet lists over long prose.
- Use **MUST / SHOULD / MUST NOT** only in RFCs and conformance documents.
- Keep passive behavior strict: no implied background jobs, no silent mutation.
- Keep backend details out of ASI rules: ASI is governance; MCP is capability; agents interpret.

### Resources

- [Agent Skills Specification](./SPEC.md) - Official format spec
- [Schema Documentation](./docs/schema/SKILL.md) - Detailed schema reference
- [Skills Reference](./docs/SKILLS.md) - Examples of existing skills
- [Skillsets Documentation](./docs/SKILLSETS.md) - Orchestrator patterns

### Community

- **Issues**: Report bugs or suggest improvements
- **Discussions**: Ask questions or propose new features
- **Pull Requests**: Review others' contributions

---

## License

By contributing to this repository, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](../LICENSE)).

---

Thank you for contributing to Agent Skills! Your contributions help improve agentic programming for everyone.
