# Procedure

## Step 1: Intake

- Confirm target skill path and goals.
- Identify required hardening focus: reliability, performance, security.

## Step 2: Initialize artifacts

- Run `scripts/init.sh --skill-path "<path>"`.
- Ensure `.asi/enhance/STATE.json` exists.

## Step 3: Inventory

- Run `python3 scripts/scan_skill.py --skill-path "<path>" --out-dir ".asi/enhance"`.
- Review `.asi/enhance/SCAN.md` for gaps.

## Step 4: Decide route

- Use `references/00_ROUTER.md` to select the correct path.

## Step 5: Draft enhancement report

- Use `.asi/enhance/ENHANCEMENT_REPORT.md`.
- Capture gaps, proposed changes, and acceptance criteria.

## Step 6: Build the enhancement plan

- Break changes into discrete tasks.
- Identify which changes are structural vs content vs scripts.
- Mark any change that touches user-facing behavior as high risk.

## Step 7: Implement (gated)

- Do not edit the target skill until the plan is approved.
- When implementation is required, hand off to `asi-exec` or explicitly enter implementation phase with approval.

## Step 8: Validate and close

- Re-run `scan_skill.py` to confirm issues are resolved.
- Update the enhancement report with results and validation notes.
