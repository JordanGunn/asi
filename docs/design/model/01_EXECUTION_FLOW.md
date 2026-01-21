# Execution Flow

## Model

```mermaid
flowchart TD
  A[User Intent<br/><small>Prompt</small>] --> B[Reasoning Contract<br/><small>Input entropy control<br/>schemas · constraints · receipts</small>]
  B --> C[Deterministic Execution<br/><small>Mechanical truth-making<br/>discovery · hashing · chunking · validation</small>]
  C --> D[Judgment Contract<br/><small>Output entropy control<br/>selection · framing · decisions</small>]
  D --> E[Artifacts & Outcomes<br/><small>Indexes · receipts · surfaced results · recommendations</small>]
```

The execution flow represents the complete lifecycle of an ASI-style skill, from user input to final output, with clear boundaries between deterministic and discretionary operations.
