from __future__ import annotations

import json
import re
from typing import Any


def load_json(raw: str) -> dict[str, Any]:
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON: {exc}") from exc
    if not isinstance(data, dict):
        raise ValueError("Top-level JSON must be an object.")
    return data


def require_str(
    data: dict[str, Any],
    key: str,
    *,
    min_length: int | None = None,
    max_length: int | None = None,
    regex: str | None = None,
    allow_missing: bool = False,
) -> str | None:
    if key not in data:
        if allow_missing:
            return None
        raise ValueError(f"Missing required field: {key}")
    val = data[key]
    if not isinstance(val, str):
        raise ValueError(f"Field '{key}' must be a string.")
    if min_length is not None and len(val) < min_length:
        raise ValueError(f"Field '{key}' must be at least {min_length} characters.")
    if max_length is not None and len(val) > max_length:
        raise ValueError(f"Field '{key}' must be at most {max_length} characters.")
    if regex is not None and not re.match(regex, val):
        raise ValueError(f"Field '{key}' does not match required pattern.")
    return val


def require_int(
    data: dict[str, Any],
    key: str,
    *,
    min_value: int | None = None,
    max_value: int | None = None,
    allow_missing: bool = False,
) -> int | None:
    if key not in data:
        if allow_missing:
            return None
        raise ValueError(f"Missing required field: {key}")
    val = data[key]
    if not isinstance(val, int):
        raise ValueError(f"Field '{key}' must be an integer.")
    if min_value is not None and val < min_value:
        raise ValueError(f"Field '{key}' must be >= {min_value}.")
    if max_value is not None and val > max_value:
        raise ValueError(f"Field '{key}' must be <= {max_value}.")
    return val


def require_bool(
    data: dict[str, Any],
    key: str,
    *,
    default: bool | None = None,
    allow_missing: bool = False,
) -> bool:
    if key not in data:
        if allow_missing:
            return default if default is not None else False
        raise ValueError(f"Missing required field: {key}")
    val = data[key]
    if not isinstance(val, bool):
        raise ValueError(f"Field '{key}' must be a boolean.")
    return val


def require_list(
    data: dict[str, Any],
    key: str,
    *,
    min_length: int | None = None,
    max_length: int | None = None,
) -> list[Any]:
    if key not in data:
        raise ValueError(f"Missing required field: {key}")
    val = data[key]
    if not isinstance(val, list):
        raise ValueError(f"Field '{key}' must be a list.")
    if min_length is not None and len(val) < min_length:
        raise ValueError(f"Field '{key}' must have at least {min_length} items.")
    if max_length is not None and len(val) > max_length:
        raise ValueError(f"Field '{key}' must have at most {max_length} items.")
    return val


def require_enum_str(
    data: dict[str, Any],
    key: str,
    *,
    allowed: list[str],
    default: str | None = None,
    allow_missing: bool = False,
) -> str:
    if key not in data:
        if allow_missing and default is not None:
            return default
        if allow_missing:
            raise ValueError(f"Missing required field: {key}")
        raise ValueError(f"Missing required field: {key}")
    val = data[key]
    if not isinstance(val, str):
        raise ValueError(f"Field '{key}' must be a string.")
    if val not in allowed:
        raise ValueError(f"Field '{key}' must be one of: {', '.join(allowed)}")
    return val

