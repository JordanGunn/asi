from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class QuestionDef:
    id: str
    prompt: str
    context: str
    decision_key: str
    answer_kind: str
    value_constraints: dict[str, Any]


QUESTION_DEFS: list[QuestionDef] = [
    QuestionDef(
        id="creator.skill_name",
        prompt="What is the skill name?",
        context="Name must be explicit and canonical (no inference).",
        decision_key="skill_name",
        answer_kind="string",
        value_constraints={
            "min_length": 1,
            "max_length": 80,
            "regex": r"^[a-z0-9][a-z0-9-]*$",
        },
    ),
    QuestionDef(
        id="creator.skill_purpose",
        prompt="What is the primary purpose of the skill?",
        context="Purpose must be explicit and scoped to a single skill capability.",
        decision_key="skill_purpose",
        answer_kind="string",
        value_constraints={
            "min_length": 1,
            "max_length": 200,
        },
    ),
    QuestionDef(
        id="creator.target_directory",
        prompt="Where should the skill live in the repo?",
        context="Provide a repo-relative directory path.",
        decision_key="target_directory",
        answer_kind="path_repo_relative",
        value_constraints={
            "min_length": 1,
            "max_length": 200,
            "must_not_start_with": ["/", "~"],
            "must_not_contain": [".."],
        },
    ),
]


def _decision_value(decisions: dict[str, Any], key: str) -> Any:
    """Extract decision value from versioned state formats."""
    if key not in decisions:
        return None
    val = decisions.get(key)
    if isinstance(val, dict) and "value" in val:
        return val.get("value")
    return val


def question_skeletons(decisions: dict[str, Any], max_questions: int = 3) -> list[dict]:
    missing = [q for q in QUESTION_DEFS if not _decision_value(decisions, q.decision_key)]
    selected = missing[:max_questions]
    return [
        {
            "id": q.id,
            "prompt": q.prompt,
            "context": q.context,
            "decision_key": q.decision_key,
            "answer_kind": q.answer_kind,
            "value_constraints": q.value_constraints,
            "option_constraints": {
                "required_fields": ["label", "value", "description", "impact"],
                "max_label_chars": 80,
                "max_value_chars": 200,
                "max_description_chars": 180,
                "max_impact_chars": 180,
                "required_impact_field": True,
                "value_must_satisfy": "value_constraints",
                "must_include_risk": False,
            },
            "fixed_option_4": {
                "label": "Respond with an alternative",
                "value": "__alternative__",
                "description": "Provide your own answer",
                "impact": "User-provided value",
            },
        }
        for q in selected
    ]


def missing_decision_ids(decisions: dict[str, Any]) -> list[str]:
    return [q.id for q in QUESTION_DEFS if not _decision_value(decisions, q.decision_key)]
