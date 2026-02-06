from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Any

from asi.creator.questions import missing_decision_ids, question_skeletons
from asi.creator.schemas import parse_apply_request, parse_suggestion_request
from asi.creator.state import load_state, save_state, stable_hash


def _hash_value(value: Any) -> str:
    raw = json.dumps(value, sort_keys=True, default=str).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def _validate_value(question: dict[str, Any], value: str) -> None:
    kind = question.get("answer_kind")
    constraints = question.get("value_constraints", {}) or {}

    if not isinstance(value, str) or not value:
        raise ValueError("Option value must be a non-empty string.")

    min_len = constraints.get("min_length")
    max_len = constraints.get("max_length")
    if min_len is not None and len(value) < int(min_len):
        raise ValueError(f"value is shorter than min_length {min_len}")
    if max_len is not None and len(value) > int(max_len):
        raise ValueError(f"value exceeds max_length {max_len}")

    if kind == "string":
        regex = constraints.get("regex")
        if regex:
            import re
            if not re.match(regex, value):
                raise ValueError("value does not match required pattern")
        return

    if kind == "path_repo_relative":
        must_not_start_with = constraints.get("must_not_start_with", [])
        for prefix in must_not_start_with:
            if value.startswith(prefix):
                raise ValueError(f"value must not start with '{prefix}'")
        must_not_contain = constraints.get("must_not_contain", [])
        for token in must_not_contain:
            if token in value:
                raise ValueError(f"value must not contain '{token}'")
        # Basic Windows absolute path guard.
        if len(value) >= 2 and value[1] == ":":
            raise ValueError("value must be repo-relative, not an absolute drive path")
        return

    raise ValueError(f"Unknown answer_kind: {kind}")


def build_reflection(decisions: dict[str, Any]) -> dict[str, Any]:
    missing = missing_decision_ids(decisions)
    summary = "All required decisions captured." if not missing else (
        "Missing required decisions: " + ", ".join(missing)
    )
    return {
        "summary": summary,
        "blockers": missing,
        "risks": [],
        "confidence": "low" if missing else "high",
        "recommendation": "ask_user" if missing else "continue",
    }


def cmd_next() -> dict[str, Any]:
    state = load_state()
    decisions = state.get("decisions", {})
    questions = question_skeletons(decisions)
    iteration_id = stable_hash({"questions": [q["id"] for q in questions]})

    status = "need_suggestions" if questions else "ready"
    return {
        "status": status,
        "iteration_id": iteration_id,
        "questions": questions,
        "reflection": build_reflection(decisions),
        "requirements": {
            "max_questions": 3,
            "options_per_question": 4,
            "recommended_option_range": [1, 3],
            "option_4_label": "Respond with an alternative",
        },
    }


def cmd_suggest(raw: str) -> dict[str, Any]:
    request = parse_suggestion_request(raw)

    expected = cmd_next()
    if expected["status"] != "need_suggestions":
        return {
            "status": "ready",
            "message": "No suggestions required.",
            "reflection": expected["reflection"],
        }

    if request["iteration_id"] != expected["iteration_id"]:
        raise ValueError("iteration_id does not match the current question set.")

    question_ids = [q["id"] for q in expected["questions"]]
    provided_ids = [s["question_id"] for s in request["suggestions"]]

    if sorted(question_ids) != sorted(provided_ids):
        raise ValueError("Suggestions must cover all questions in this iteration.")

    ask_questions = []
    for q in expected["questions"]:
        suggestion = next(s for s in request["suggestions"] if s["question_id"] == q["id"])
        options = [
            {
                "label": opt["label"],
                "value": opt["value"],
                "description": opt["description"],
                "impact": opt["impact"],
            }
            for opt in suggestion["options"]
        ]

        for opt in options:
            _validate_value(q, opt["value"])

        options.append(q["fixed_option_4"])

        ask_questions.append(
            {
                "id": q["id"],
                "decision_key": q.get("decision_key"),
                "answer_kind": q.get("answer_kind"),
                "value_constraints": q.get("value_constraints", {}),
                "prompt": q["prompt"],
                "context": q["context"],
                "options": options,
                "recommended": suggestion["recommended"],
            }
        )

    ask_set = {
        "iteration_id": request["iteration_id"],
        "questions": ask_questions,
    }
    ask_set_id = stable_hash(ask_set)

    state = load_state()
    state["last_ask_set"] = {
        "ask_set_id": ask_set_id,
        "ask_set": ask_set,
    }
    save_state(state)

    return {
        "status": "need_answers",
        "ask_set_id": ask_set_id,
        "questions": ask_questions,
        "reflection": expected["reflection"],
    }


def cmd_apply(raw: str) -> dict[str, Any]:
    request = parse_apply_request(raw)

    state = load_state()
    last = state.get("last_ask_set", {})
    if not last or last.get("ask_set_id") != request["ask_set_id"]:
        raise ValueError("ask_set_id does not match the latest ask set.")

    ask_set = last.get("ask_set", {})
    questions = {q["id"]: q for q in ask_set.get("questions", [])}

    answer_ids = [a["question_id"] for a in request["answers"]]
    if sorted(answer_ids) != sorted(questions.keys()):
        raise ValueError("Answers must cover all questions in the latest ask set.")

    for answer in request["answers"]:
        if answer["question_id"] not in questions:
            raise ValueError(f"Unknown question_id: {answer['question_id']}")
        if answer["selection"] == 4 and not answer.get("alternative_text"):
            raise ValueError("alternative_text is required when selection is 4.")
        if not answer.get("user_confirmation", False):
            return {
                "status": "need_answers",
                "message": "User confirmation required before applying decisions.",
                "reflection": build_reflection(state.get("decisions", {})),
                "ask_set_id": request["ask_set_id"],
                "questions": list(questions.values()),
            }

    decisions: dict[str, Any] = state.get("decisions", {})
    for answer in request["answers"]:
        question = questions[answer["question_id"]]
        if answer["selection"] in (1, 2, 3):
            chosen_value = question["options"][answer["selection"] - 1]["value"]
            chosen_label = question["options"][answer["selection"] - 1]["label"]
            chosen_source = "option"
        else:
            chosen_value = answer.get("alternative_text")
            chosen_label = "(alternative)"
            chosen_source = "alternative"

        if chosen_value is None:
            raise ValueError("Internal error: chosen value is None")

        _validate_value(question, str(chosen_value))

        decision_key = question.get("decision_key")
        if not decision_key:
            raise ValueError(f"Question missing decision_key: {answer['question_id']}")

        decisions[decision_key] = {
            "value": chosen_value,
            "source": chosen_source,
            "ask_set_id": request["ask_set_id"],
        }

        state["decision_log"].append(
            {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "question_id": answer["question_id"],
                "selection": answer["selection"],
                "decision_key": decision_key,
                "ask_set_id": request["ask_set_id"],
                "value": chosen_value,
                "value_label": chosen_label,
                "value_hash": _hash_value(chosen_value),
                "confirmed": answer.get("user_confirmation", False),
            }
        )

    state["decisions"] = decisions
    state["last_ask_set"] = {}
    save_state(state)

    next_state = cmd_next()
    return {
        "status": next_state["status"],
        "next_action": "continue_loop" if next_state["status"] != "ready" else "execute_phase",
        "reflection": next_state["reflection"],
    }


#
# Note: decision_key is carried through question skeletons and ask sets,
# so we do not maintain hard-coded mapping here.
