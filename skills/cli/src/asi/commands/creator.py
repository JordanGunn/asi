from __future__ import annotations

from asi.creator.loop import cmd_apply, cmd_next, cmd_suggest
from asi.creator.schemas import (
    emit_creator_apply_schema,
    emit_creator_run_schema,
    emit_creator_schema,
    emit_creator_suggest_schema,
    parse_creator_run_plan,
)
from asi.creator.state import stable_hash


def emit_schema(kind: str = "run") -> dict:
    if kind == "run":
        return emit_creator_schema()
    if kind == "suggest":
        return emit_creator_suggest_schema()
    if kind == "apply":
        return emit_creator_apply_schema()
    raise ValueError("unknown schema kind")


def emit_run_schema() -> dict:
    return emit_creator_run_schema()


def emit_suggest_schema() -> dict:
    return emit_creator_suggest_schema()


def emit_apply_schema() -> dict:
    return emit_creator_apply_schema()


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
