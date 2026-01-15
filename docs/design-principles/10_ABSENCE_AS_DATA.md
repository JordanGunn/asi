# 10. Treat Absence as Data

What is not present is often as important as what is.

- Empty results, missing files, no matches, or unchanged hashes should be surfaced explicitly.
- Silence should not be ambiguous.
- “Nothing happened” is a meaningful outcome and should be represented as one.

This prevents agents from inventing activity where none occurred.

## Why this matters for ASI

ASI prefers loud, explicit outcomes over ambiguous silence. Treating absence as data supports clear failure semantics and trustworthy reporting when “nothing happened” is the correct result (`docs/spec/rfc-0001-asi.md`, `docs/spec/rfc-0003-conformance.md`).
