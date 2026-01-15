from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def short_hash(text: str, n: int = 12) -> str:
    h = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return h[:n]


def yaml_load(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def yaml_dump(data: Any, path: Path) -> None:
    text = yaml.safe_dump(
        data,
        sort_keys=True,
        default_flow_style=False,
        allow_unicode=True,
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _repo_root_from(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / "pyproject.toml").exists() and (p / "skills").exists():
            return p
    return start


def repo_root_from_file(file: Path) -> Path:
    skill_dir = file.resolve().parents[2]
    return _repo_root_from(skill_dir)
