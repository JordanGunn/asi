# Summary

The **plan** skill provides agent-optimized planning for programming sessions. It creates, manages, and tracks structured plans with deterministic state management. Plans persist across sessions via `.plan/active.yaml` and `.plan/active/STATE.json`. The agent's role is limited to translating user intent into step descriptions and deciding when to mark steps complete—all structural operations are handled by scripts.
