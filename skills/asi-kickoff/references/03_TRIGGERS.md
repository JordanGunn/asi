# Invocation Criteria

## ✅ Invoke when

- User explicitly requests a skill design kickoff
- User wants to plan a new ASI-compliant skill
- User asks to "scaffold" or "design" a skill before implementation
- User references the kickoff workflow or procedure

## ❌ Do not invoke when

- User wants to implement a skill (use `asi-exec` after planning)
- User wants to decompose an existing kickoff (use `asi-plan`)
- User is asking general questions about ASI
- A KICKOFF.md already exists and user has not requested fresh start
- User intent is ambiguous or underspecified

## 🛑 Stop immediately if

- User cannot provide explicit skill name
- User cannot provide explicit skill purpose
- Target directory is not writable
- ASI specification documents are not accessible
- User withdraws consent mid-procedure
