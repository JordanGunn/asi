---
description: Failure modes and handling for sniff-locate.
index:
  - Cases
---

# Failures

## Cases

- If `.sniff/findings.jsonl` is missing, listing yields no results.
- If a file path no longer exists, findings become `missing`.
- If reanchor cannot find a match, findings remain `missing`.
