from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from asi.util.jsonio import read_json, write_json
from asi.util.paths import repo_root, ensure_dir


def state_path() -> Path:
    return creator_root() / "state.json"


def creator_root() -> Path:
    return repo_root() / ".asi" / "creator"


def ask_sets_dir() -> Path:
    return creator_root() / "ask_sets"


def receipts_dir() -> Path:
    return creator_root() / "receipts"


def decision_log_jsonl_path() -> Path:
    return creator_root() / "decisions.log.jsonl"


def artifact_model() -> dict[str, Any]:
    root = creator_root()
    return {
        "version": "v1-session",
        "canonical_paths": {
            "state": str(root / "state.json"),
            "ask_sets": str(root / "ask_sets"),
            "decision_log": str(root / "decisions.log.jsonl"),
            "receipts": str(root / "receipts"),
        },
        "legacy_paths": {
            "creator_kickoff": str(root / "kickoff"),
            "creator_plan": str(root / "plan"),
            "creator_exec": str(root / "exec"),
            "global_kickoff": str(repo_root() / ".asi" / "kickoff"),
            "global_plan": str(repo_root() / ".asi" / "plan"),
            "global_exec": str(repo_root() / ".asi" / "exec"),
        },
    }


def _legacy_paths_present() -> list[Path]:
    model = artifact_model()
    out: list[Path] = []
    for _name, path in model["legacy_paths"].items():
        p = Path(path)
        if p.exists():
            out.append(p)
    return out


def legacy_warnings() -> list[dict[str, str]]:
    present = _legacy_paths_present()
    if not present:
        return []
    return [
        {
            "code": "creator_legacy_artifacts_detected",
            "message": (
                "Legacy kickoff/plan/exec artifacts are deprecated for creator runtime. "
                "Use session artifacts under .asi/creator/{state.json,ask_sets,decisions.log.jsonl,receipts}."
            ),
            "sunset_release": "next",
        }
    ]


def _migrate_to_v2(state: dict[str, Any]) -> dict[str, Any]:
    """Upgrade state to version 2 without losing information."""
    decisions = state.get("decisions", {})
    migrated: dict[str, Any] = {}

    for key, val in decisions.items():
        if isinstance(val, dict) and "value" in val:
            migrated[key] = val
        else:
            migrated[key] = {"value": val, "source": "legacy", "ask_set_id": ""}

    state["version"] = 2
    state["decisions"] = migrated
    log = state.get("decision_log", [])
    log.append({"event": "migrated_to_v2"})
    state["decision_log"] = log
    return state


def load_state() -> dict[str, Any]:
    path = state_path()
    state = read_json(path) if path.exists() else {}
    state.setdefault("version", 1)
    state.setdefault("decisions", {})
    state.setdefault("decision_log", [])
    state.setdefault("last_ask_set", {})
    if state.get("version", 1) < 2:
        state = _migrate_to_v2(state)
    return state


def save_state(state: dict[str, Any]) -> None:
    path = state_path()
    ensure_dir(path.parent)
    write_json(path, state)


def write_ask_set_snapshot(ask_set_id: str, ask_set: dict[str, Any]) -> Path:
    path = ask_sets_dir() / f"{ask_set_id}.json"
    write_json(path, {"ask_set_id": ask_set_id, "ask_set": ask_set})
    return path


def append_decision_event(event: dict[str, Any]) -> Path:
    path = decision_log_jsonl_path()
    ensure_dir(path.parent)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(event, sort_keys=True) + "\n")
    return path


def write_receipt(payload: dict[str, Any]) -> Path:
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    path = receipts_dir() / f"{ts}.json"
    write_json(path, payload)
    return path


def stable_hash(data: dict[str, Any]) -> str:
    raw = json.dumps(data, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()
