# 06. Separate Discovery, Decision, and Mutation

Keep these phases distinct.

- Discovery (deterministic): establish facts, enumerate state, surface candidates
- Decision (agent): select, prioritize, or interpret among surfaced options
- Mutation (deterministic): apply changes exactly as decided

This separation prevents decisions based on incomplete or imagined information and keeps mutation auditable.

## Why this matters for ASI

This supports strict passivity and observability: discovery and narrowing define what is in-bounds; mutation is explicit and attributable; validation gates completion (`docs/spec/rfc-0001-asi.md`).
