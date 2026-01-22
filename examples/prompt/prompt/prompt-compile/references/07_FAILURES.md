---
description: What to do when things go wrong.
index:
  - Failure Modes
  - Recovery
---

# Failures

## Failure Modes

1. **No artifact** — `.prompt/active.yaml` does not exist
2. **Compile fails** — script execution fails or produces invalid output
3. **Artifact not ready** — `status` is not `ready`
4. **Polish introduces errors** — markdown no longer matches the artifact intent

## Recovery

- Prefer re-running deterministic compilation over manual patching
- Preserve `.prompt/active.yaml` for re-compilation
