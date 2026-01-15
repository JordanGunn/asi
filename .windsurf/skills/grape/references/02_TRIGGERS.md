---
description: Signals for when to invoke or exit grape.
index:
  - Invoke when
  - Do not invoke when
  - Exit immediately if
---

# Triggers

## Invoke when

- You need to locate likely files, modules, or directories before reading.
- A user request contains vague intent, overloaded terms, or likely misnaming.
- You suspect tunnel-vision and want a breadth-first surface scan.

## Do not invoke when

- The user explicitly asked to inspect a specific file and you already have the path.
- The task is purely conceptual and does not depend on repo contents.

## Exit immediately if

- The user requests conclusions from matches without reading relevant code.
- Search results are treated as proof of absence without controlled widening.
