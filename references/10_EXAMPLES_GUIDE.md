# Examples Guide

Examples in this repository exist to illustrate existing rules, not to expand scope.

## Rules for new examples

- Start with a concrete scenario that matches a real expectation failure.
- Show the unconstrained version and why it is non-compliant.
- Show a deterministic reduction that bounds scope before reasoning.
- Keep passive behavior strict: no implied auto-actions.
- Make the failure condition explicit (what must fail loudly).
- Avoid backend or server coupling; keep examples generic.

