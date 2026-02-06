from __future__ import annotations

from typing import Any

from asi.util.validate import load_json, require_list, require_str


def emit_onboard_schema() -> dict[str, Any]:
    return {
        "type": "object",
        "properties": {
            "topic": {"type": "string", "minLength": 1, "description": "Short onboarding topic"},
            "entrypoints": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Optional entrypoints to read (paths or URLs)",
            },
        },
        "required": ["topic"],
        "additionalProperties": False,
    }


def parse_onboard_plan(raw: str) -> dict[str, Any]:
    data = load_json(raw)
    topic = require_str(data, "topic", min_length=1, max_length=200)
    entrypoints = []
    if "entrypoints" in data:
        entrypoints = require_list(data, "entrypoints", min_length=0, max_length=200)
        for i, item in enumerate(entrypoints):
            if not isinstance(item, str):
                raise ValueError(f"entrypoints[{i}] must be a string.")

    return {"topic": topic, "entrypoints": entrypoints}

