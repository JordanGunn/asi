from __future__ import annotations

import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def sha256_bytes(data: bytes) -> str:
    h = hashlib.sha256()
    h.update(data)
    return f"sha256:{h.hexdigest()}"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return f"sha256:{h.hexdigest()}"


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


def read_contract(contract_path: Path) -> dict[str, Any] | None:
    if not contract_path.exists():
        return None
    data = yaml_load(contract_path)
    if data is None:
        return None
    if not isinstance(data, dict):
        raise ValueError("contract is not a mapping")
    return data


def read_forget(forget_path: Path) -> Any:
    if not forget_path.exists():
        return None
    data = yaml_load(forget_path)
    if data is None:
        return None
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        return data
    raise ValueError("forget file is not a list or mapping")
