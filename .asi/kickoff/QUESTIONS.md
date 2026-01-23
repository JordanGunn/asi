---
timestamp: "2026-01-23T20:29:39Z"
skill_name: "plan"
---

# Open Questions: plan

Questions captured during kickoff. Do not answer—capture only.

## Unresolved

- [ ] 

## Resolved

<!-- Move resolved questions here with answers -->

- [ ] Should plans support nested sub-steps or remain flat?
  - Context: Flat is simpler and more deterministic, but nested may be useful for complex tasks. Current design is flat.
  - Answer: Plans should support sub-steps if the agent thiks this is reasonable and helpful for other agents. Otherwise, plans should remain flat.
- [ ] Should there be a maximum number of steps per plan?
  - Context: Unbounded lists can become unwieldy. Consider soft limit with warning vs hard limit.
  - Answer: Plans should require as many steps as the agent thinks is necessary to properly decompose the work into atomic tasks.
- [ ] How should plan resumption work across different agents/sessions?
  - Context: STATE.json provides persistence, but agent context is lost. Consider handoff notes field.
  - Answer: Plans should be resumable across agents/sessions. Artifacts can be used for this.
