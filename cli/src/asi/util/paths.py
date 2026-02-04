from __future__ import annotations

from pathlib import Path


def repo_root(start: Path | None = None) -> Path:
    """Resolve repo root by walking up from start until .git or pyproject.toml."""
    current = (start or Path.cwd()).resolve()
    for _ in range(20):
        if (current / ".git").exists():
            return current
        if (current / "pyproject.toml").exists():
            return current
        if current.parent == current:
            break
        current = current.parent
    return (start or Path.cwd()).resolve()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)
