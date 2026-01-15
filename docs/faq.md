# FAQ

## Is ASI a protocol?

No. ASI is a behavioral contract (governance layer). It does not define transports, wire formats, or backend APIs.

## Does ASI replace MCP?

No. MCP provides capability and persistence. ASI governs behavior: when reasoning is allowed, how scope is constructed, what may mutate, and how failures surface.

## Does ASI make agents smarter?

No. ASI is not a model improvement. It makes systems trustworthy by constraining scope and sequencing and by enforcing observability and explicit failure semantics.

## Why can’t “passive behavior” auto-fix things?

Because passive means passive: systems may observe and report, but they must not mutate state without explicit user intent. Auto-repair and background mutation recreate the expectation problem by turning capability into implied behavior.

## Why do I need deterministic reduction?

Because agents must not reason over undefined reality. Deterministic discovery and narrowing bound the surface so that reasoning is auditable, reproducible, and not a substitute for missing ground truth.

