"""Parse and manage prompt artifacts."""

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml
from jsonschema import Draft7Validator, FormatChecker


def find_repo_root(start: Path) -> Path:
    current = start.resolve()
    for parent in [current, *current.parents]:
        if (parent / "nunchuck.toml").exists() or (parent / ".git").exists():
            return parent
    return current


REPO_ROOT = find_repo_root(Path(__file__).resolve())
PROMPT_DIR = REPO_ROOT / ".prompt"
ACTIVE_PATH = PROMPT_DIR / "active.yaml"
RECEIPTS_DIR = PROMPT_DIR / "receipts"

SKILL_DIR = Path(__file__).resolve().parents[2]
ASSETS_DIR = SKILL_DIR / "assets"
ARTIFACT_SCHEMA_PATH = ASSETS_DIR / "prompt-artifact-schema.json"
RECEIPT_SCHEMA_PATH = ASSETS_DIR / "receipt-schema.json"

VALID_STATUSES = ("drafting", "ready", "executed")


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def to_rfc3339(dt: datetime) -> str:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def compute_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def ensure_prompt_dir() -> None:
    PROMPT_DIR.mkdir(exist_ok=True)


def ensure_receipts_dir() -> None:
    ensure_prompt_dir()
    RECEIPTS_DIR.mkdir(exist_ok=True)


def artifact_exists() -> bool:
    return ACTIVE_PATH.exists()


def load_artifact() -> dict[str, Any] | None:
    if not artifact_exists():
        return None
    content = ACTIVE_PATH.read_text(encoding="utf-8")
    return yaml.safe_load(content)


def save_artifact(artifact: dict[str, Any]) -> None:
    ensure_prompt_dir()
    artifact["updated_at"] = to_rfc3339(now_utc())
    content = yaml.dump(artifact, default_flow_style=False, allow_unicode=True, sort_keys=False)
    ACTIVE_PATH.write_text(content, encoding="utf-8")


def delete_artifact() -> bool:
    if artifact_exists():
        ACTIVE_PATH.unlink()
        return True
    return False


def create_empty_artifact() -> dict[str, Any]:
    now = to_rfc3339(now_utc())
    return {
        "version": "1",
        "status": "drafting",
        "created_at": now,
        "updated_at": now,
        "intent": {
            "objective": "",
            "constraints": [],
            "assumptions": [],
            "open_questions": [],
        },
        "prompt": "",
        "quality": None,
    }


def _load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _schema_errors(schema: dict[str, Any], instance: dict[str, Any]) -> list[str]:
    validator = Draft7Validator(schema, format_checker=FormatChecker())
    errors = sorted(validator.iter_errors(instance), key=lambda e: list(e.path))
    formatted: list[str] = []
    for err in errors:
        path = ".".join(str(p) for p in err.path) or "(root)"
        formatted.append(f"{path}: {err.message}")
    return formatted


def validate_artifact(artifact: dict[str, Any]) -> list[str]:
    if not isinstance(artifact, dict):
        return ["artifact is not a dictionary"]

    if not ARTIFACT_SCHEMA_PATH.exists():
        return [f"missing artifact schema: {ARTIFACT_SCHEMA_PATH}"]

    schema = _load_json(ARTIFACT_SCHEMA_PATH)
    errors = _schema_errors(schema, artifact)

    return errors


def validate_receipt(receipt: dict[str, Any]) -> list[str]:
    if not RECEIPT_SCHEMA_PATH.exists():
        return [f"missing receipt schema: {RECEIPT_SCHEMA_PATH}"]

    schema = _load_json(RECEIPT_SCHEMA_PATH)
    return _schema_errors(schema, receipt)


def write_receipt(artifact: dict[str, Any], *, execution_status: str) -> Path:
    ensure_receipts_dir()

    prompt_text = artifact.get("prompt", "")
    artifact_hash = compute_hash(prompt_text)
    timestamp = to_rfc3339(now_utc()).replace(":", "-")

    receipt = {
        "version": "1",
        "executed_at": to_rfc3339(now_utc()),
        "artifact_hash": artifact_hash,
        "prompt_text": prompt_text,
        "execution_status": execution_status,
        "execution_context": {
            "working_directory": str(REPO_ROOT),
        },
    }

    errors = validate_receipt(receipt)
    if errors:  # pragma: no cover
        raise ValueError("receipt does not match schema: " + "; ".join(errors))

    filename = f"{timestamp}-{artifact_hash[:8]}.json"
    receipt_path = RECEIPTS_DIR / filename

    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    return receipt_path


def list_receipts() -> list[Path]:
    if not RECEIPTS_DIR.exists():
        return []
    return sorted(RECEIPTS_DIR.glob("*.json"))


COMPILED_PATH = PROMPT_DIR / "PROMPT.md"


def compile_to_markdown(artifact: dict[str, Any]) -> str:
    intent = artifact.get("intent", {})

    lines: list[str] = []
    lines.append("# Prompt")
    lines.append("")

    objective = intent.get("objective", "").strip()
    if objective:
        lines.append("## Objective")
        lines.append("")
        lines.append(objective)
        lines.append("")

    constraints = intent.get("constraints", [])
    if constraints:
        lines.append("## Constraints")
        lines.append("")
        lines.append("The following constraints must be respected:")
        lines.append("")
        for c in constraints:
            lines.append(f"- {c}")
        lines.append("")

    assumptions = intent.get("assumptions", [])
    if assumptions:
        lines.append("## Assumptions")
        lines.append("")
        lines.append("The following assumptions are in effect:")
        lines.append("")
        for a in assumptions:
            lines.append(f"- {a}")
        lines.append("")

    prompt_text = artifact.get("prompt", "").strip()
    if prompt_text:
        lines.append("## Prompt Text")
        lines.append("")
        lines.append(prompt_text)
        lines.append("")

    quality = artifact.get("quality")
    if quality and isinstance(quality, dict):
        clarity = quality.get("clarity_score")
        completeness = quality.get("completeness_score")
        validated_at = quality.get("validated_at")
        if clarity is not None or completeness is not None or validated_at:
            lines.append("## Quality")
            lines.append("")
            if clarity is not None:
                lines.append(f"- clarity_score: {clarity}")
            if completeness is not None:
                lines.append(f"- completeness_score: {completeness}")
            if validated_at:
                lines.append(f"- validated_at: {validated_at}")
            lines.append("")

    return "\n".join(lines)


def write_compiled(content: str) -> Path:
    ensure_prompt_dir()
    COMPILED_PATH.write_text(content, encoding="utf-8")
    return COMPILED_PATH


def compiled_exists() -> bool:
    return COMPILED_PATH.exists()
