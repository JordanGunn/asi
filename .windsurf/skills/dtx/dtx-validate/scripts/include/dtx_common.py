from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Any

import yaml


def sha256_bytes(data: bytes) -> str:
    h = hashlib.sha256()
    h.update(data)
    return f"sha256:{h.hexdigest()}"


def yaml_load(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def _repo_root_from(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / "pyproject.toml").exists() and (p / "skills").exists():
            return p
    return start


def repo_root_from_file(file: Path) -> Path:
    skill_dir = file.resolve().parents[2]
    return _repo_root_from(skill_dir)
