---
name: asi-enhance
description: Enhance an existing skill into an ASI-aligned structure with stronger reliability, performance, and security. Use when you need to upgrade, harden, or refactor a skill (including an existing ASI skill), produce enhancement artifacts, or standardize a skill's structure, scripts, references, and validation workflow.
---

# INSTRUCTIONS

1. Run `scripts/init.sh --skill-path "<path>"` to create `.asi/enhance` artifacts.
2. Run `python3 scripts/scan_skill.py --skill-path "<path>" --out-dir ".asi/enhance"` to inventory the skill.
3. Read `references/00_ROUTER.md` and follow the routed procedure.
4. Record findings and decisions in `.asi/enhance/ENHANCEMENT_REPORT.md` using the template in `assets/templates/ENHANCEMENT_REPORT.template.md`.
5. Do not implement changes until an enhancement plan is approved; if implementation is requested, hand off to `asi-exec` or explicitly enter an implementation phase with user approval.
