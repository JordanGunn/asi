# Invocation Criteria

## ✅ Invoke when

- User asks to create a plan
- User asks to add a step or task
- User asks to mark something done or complete
- User asks for plan status
- User asks to archive or clear the plan

## ❌ Do not invoke when

- User is asking about a different kind of plan (e.g., subscription plan)
- User wants to execute tasks (use appropriate execution skill)
- User wants to modify plan structure beyond adding steps

## 🛑 Stop immediately if

- Plan file is corrupted
- STATE.json is missing when expected
- User withdraws request
