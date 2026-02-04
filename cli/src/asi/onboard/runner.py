from __future__ import annotations

import json

from asi.onboard.schemas import parse_onboard_plan


def run_plan(raw: str) -> dict:
    plan = parse_onboard_plan(raw)
    return {
        "status": "ready",
        "message": "Onboard plan accepted. Execution is CLI-owned and deterministic.",
        "plan": plan,
    }
