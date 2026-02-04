from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from asi.util.jsonio import read_json, write_json
from asi.util.paths import repo_root, ensure_dir


def state_path() -> Path:
    return repo_root() / ".asi" / "creator" / "state.json"


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


def stable_hash(data: dict[str, Any]) -> str:
    raw = json.dumps(data, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()
