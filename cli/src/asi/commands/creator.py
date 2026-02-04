from __future__ import annotations

from asi.creator.loop import cmd_apply, cmd_next, cmd_suggest
from asi.creator.schemas import emit_creator_schema, parse_creator_run_plan
from asi.creator.state import stable_hash


def emit_schema() -> dict:
    return emit_creator_schema()


def cmd_run(raw: str) -> dict:
    plan = parse_creator_run_plan(raw)
    # Run currently returns the same output as `next` for interactive flow.
    result = cmd_next()
    result["plan"] = plan
    result["run_id"] = stable_hash(plan)
    return result


def cmd_next_json() -> dict:
    return cmd_next()


def cmd_suggest_json(raw: str) -> dict:
    return cmd_suggest(raw)


def cmd_apply_json(raw: str) -> dict:
    return cmd_apply(raw)
