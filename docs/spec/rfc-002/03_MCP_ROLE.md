# MCP’s role (capability, not policy)

MCP provides a way to expose capabilities such as:

- tool execution
- persistent stores (including “memory”)
- external integrations

MCP does not, by itself, define:

- when tools should run
- what scope is allowed
- what constitutes safe mutation
- what failure must look like

Those are governance questions, and they belong in ASI.
