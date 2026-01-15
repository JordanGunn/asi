# Agent behavior

- **Best practice:** emit receipts before execution (plan must be produced before running commands).
- **Request permission** before any bootstrap action.
- **Fail clearly** with explicit error messages for missing dependencies or invalid contracts.

Agents should never infer a workable environment or silently install missing pieces.
