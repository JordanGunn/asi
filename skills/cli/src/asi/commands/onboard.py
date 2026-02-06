from __future__ import annotations

from asi.onboard.runner import run_plan
from asi.onboard.schemas import emit_onboard_schema


def emit_schema() -> dict:
    return emit_onboard_schema()


def cmd_run(raw: str) -> dict:
    return run_plan(raw)
