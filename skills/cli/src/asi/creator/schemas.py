from __future__ import annotations

from typing import Any

from asi.util.validate import (
    load_json,
    require_bool,
    require_enum_str,
    require_int,
    require_list,
    require_str,
)
from asi.creator.state import artifact_model


def emit_creator_run_schema() -> dict[str, Any]:
    """JSON Schema for `asi creator run --stdin` plan input."""
    return {
        "type": "object",
        "x-artifact-model": artifact_model(),
        "properties": {
            "goal": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500,
                "description": "High-level goal for the creator workflow",
            },
            "phase": {
                "type": "string",
                "enum": ["kickoff", "plan", "exec", "auto"],
                "default": "auto",
                "description": "Legacy phase hint (deprecated). Creator runtime is session-loop driven.",
            },
        },
        "required": ["goal"],
        "additionalProperties": False,
    }


def emit_creator_suggest_schema() -> dict[str, Any]:
    """JSON Schema for `asi creator suggest --stdin` input."""
    option_schema = {
        "type": "object",
        "properties": {
            "label": {"type": "string", "minLength": 1, "maxLength": 80},
            "value": {"type": "string", "minLength": 1, "maxLength": 200},
            "description": {"type": "string", "minLength": 1, "maxLength": 180},
            "impact": {"type": "string", "minLength": 1, "maxLength": 180},
        },
        "required": ["label", "value", "description", "impact"],
        "additionalProperties": False,
    }
    suggestion_schema = {
        "type": "object",
        "properties": {
            "question_id": {"type": "string", "minLength": 1, "maxLength": 120},
            "options": {
                "type": "array",
                "minItems": 3,
                "maxItems": 3,
                "items": option_schema,
            },
            "recommended": {"type": "integer", "minimum": 1, "maximum": 3},
            "rationale": {"type": "object"},
        },
        "required": ["question_id", "options", "recommended"],
        "additionalProperties": False,
    }
    return {
        "type": "object",
        "properties": {
            "iteration_id": {"type": "string", "minLength": 1, "maxLength": 200},
            "suggestions": {
                "type": "array",
                "minItems": 1,
                "maxItems": 3,
                "items": suggestion_schema,
            },
        },
        "required": ["iteration_id", "suggestions"],
        "additionalProperties": False,
    }


def emit_creator_apply_schema() -> dict[str, Any]:
    """JSON Schema for `asi creator apply --stdin` input."""
    answer_schema = {
        "type": "object",
        "properties": {
            "question_id": {"type": "string", "minLength": 1, "maxLength": 120},
            "selection": {"type": "integer", "minimum": 1, "maximum": 4},
            "alternative_text": {"type": "string", "minLength": 1, "maxLength": 500},
            "user_confirmation": {"type": "boolean"},
        },
        "required": ["question_id", "selection"],
        "additionalProperties": False,
    }
    return {
        "type": "object",
        "properties": {
            "ask_set_id": {"type": "string", "minLength": 1, "maxLength": 200},
            "confirmed": {"type": "boolean"},
            "answers": {
                "type": "array",
                "minItems": 1,
                "maxItems": 3,
                "items": answer_schema,
            },
            "notes": {"type": "string", "minLength": 1, "maxLength": 2000},
        },
        "required": ["ask_set_id", "answers"],
        "additionalProperties": False,
    }


def emit_creator_schema() -> dict[str, Any]:
    """Compatibility alias for run schema emission."""
    return emit_creator_run_schema()


def parse_creator_run_plan(raw: str) -> dict[str, Any]:
    data = load_json(raw)
    goal = require_str(data, "goal", min_length=1, max_length=500)
    phase = require_enum_str(
        data,
        "phase",
        allowed=["kickoff", "plan", "exec", "auto"],
        default="auto",
        allow_missing=True,
    )
    return {"goal": goal, "phase": phase}


def _require_object(item: Any, *, context: str) -> dict[str, Any]:
    if not isinstance(item, dict):
        raise ValueError(f"{context} must be an object.")
    return item


def parse_suggestion_request(raw: str) -> dict[str, Any]:
    data = load_json(raw)
    iteration_id = require_str(data, "iteration_id", min_length=1, max_length=200)
    suggestions = require_list(data, "suggestions", min_length=1, max_length=3)

    parsed_suggestions: list[dict[str, Any]] = []
    for i, item in enumerate(suggestions):
        s = _require_object(item, context=f"suggestions[{i}]")
        question_id = require_str(s, "question_id", min_length=1, max_length=120)
        options = require_list(s, "options", min_length=3, max_length=3)
        recommended = require_int(s, "recommended", min_value=1, max_value=3)

        rationale = s.get("rationale", {})
        if rationale is None:
            rationale = {}
        if not isinstance(rationale, dict):
            raise ValueError(f"suggestions[{i}].rationale must be an object.")

        parsed_options: list[dict[str, Any]] = []
        for j, opt in enumerate(options):
            o = _require_object(opt, context=f"suggestions[{i}].options[{j}]")
            label = require_str(o, "label", min_length=1, max_length=80)
            value = require_str(o, "value", min_length=1, max_length=200)
            description = require_str(o, "description", min_length=1, max_length=180)
            impact = require_str(o, "impact", min_length=1, max_length=180)
            parsed_options.append(
                {"label": label, "value": value, "description": description, "impact": impact}
            )

        parsed_suggestions.append(
            {
                "question_id": question_id,
                "options": parsed_options,
                "recommended": int(recommended) if recommended is not None else 1,
                "rationale": rationale,
            }
        )

    return {"iteration_id": iteration_id, "suggestions": parsed_suggestions}


def parse_apply_request(raw: str) -> dict[str, Any]:
    data = load_json(raw)
    ask_set_id = require_str(data, "ask_set_id", min_length=1, max_length=200)
    confirmed = require_bool(data, "confirmed", default=False, allow_missing=True)
    answers = require_list(data, "answers", min_length=1, max_length=3)
    notes = require_str(data, "notes", min_length=1, max_length=2000, allow_missing=True)

    parsed_answers: list[dict[str, Any]] = []
    for i, item in enumerate(answers):
        a = _require_object(item, context=f"answers[{i}]")
        question_id = require_str(a, "question_id", min_length=1, max_length=120)
        selection = require_int(a, "selection", min_value=1, max_value=4)

        alternative_text = require_str(
            a,
            "alternative_text",
            min_length=1,
            max_length=500,
            allow_missing=True,
        )
        answer_confirmed = require_bool(
            a,
            "user_confirmation",
            default=False,
            allow_missing=True,
        )

        if selection == 4 and not alternative_text:
            raise ValueError("alternative_text is required when selection is 4.")

        parsed_answers.append(
            {
                "question_id": question_id,
                "selection": selection,
                "alternative_text": alternative_text,
                "user_confirmation": answer_confirmed,
            }
        )

    out: dict[str, Any] = {
        "ask_set_id": ask_set_id,
        "confirmed": confirmed,
        "answers": parsed_answers,
    }
    if notes:
        out["notes"] = notes
    return out
