# Scripts Specifications Overview

This section defines the canonical behavior for skill wrapper scripts and their relationship to the agent-owned CLI boundary.

Wrapper scripts are deterministic entrypoints. They do not implement behavior; they delegate to the CLI and enforce a stable interface for agents.
