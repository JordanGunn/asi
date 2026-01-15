# Determinism rules

- **Explicit scope:** all include/exclude rules are declared and reportable.
- **Stable ordering:** discovery and execution lists are ordered deterministically.
- **Explicit absence:** missing inputs, empty result sets, and skipped steps are reported.
- **Bounded expansion:** any scope widening is constrained, justified, and reported.

These rules prevent hidden reasoning from silently changing what is in-bounds.
