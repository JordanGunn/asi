# Alternatives and tradeoffs

**Alternatives:**

- PEX/zipapp bundling
- System Python with pinned versions
- Prebuilt binaries

**Tradeoffs of venv-based bootstrap:**

- extra disk usage
- first-run latency
- more moving parts to validate

**When to choose auto-bootstrap vs explicit consent:**

- Prefer explicit consent when the environment may change or when installs are non-trivial.
- Auto-bootstrap is only reasonable in fully sandboxed, disposable environments with prior user agreement.
