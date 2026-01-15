from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


@dataclass(frozen=True)
class Range:
    start: int
    end: int


def utcnow_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def sha1_hex(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


_COMMENT_ONLY_RE = re.compile(r"^\s*(#|//).*$")
_WS_RE = re.compile(r"\s+")


def normalize(text: str, *, drop_comment_only: bool = True) -> str:
    lines: list[str] = []
    for raw in text.splitlines():
        s = raw.strip()
        if not s:
            continue
        if drop_comment_only and _COMMENT_ONLY_RE.match(s):
            continue
        s = _WS_RE.sub(" ", s)
        lines.append(s)
    return "\n".join(lines)


def make_excerpt(text: str, *, max_chars: int = 2000) -> str:
    norm = normalize(text)
    if len(norm) <= max_chars:
        return norm
    return norm[:max_chars]


def make_anchor(file_lines: list[str], r: Range) -> dict[str, Any]:
    start = max(1, r.start)
    end = max(start, r.end)
    before = file_lines[start - 2].rstrip("\n") if start - 2 >= 0 else ""
    core = "".join(file_lines[start - 1 : end])
    after = file_lines[end].rstrip("\n") if end < len(file_lines) else ""

    before_ex = make_excerpt(before)
    core_ex = make_excerpt(core)
    after_ex = make_excerpt(after)

    core_hash = sha1_hex(core_ex)
    window_hash = sha1_hex(make_excerpt(before_ex + "\n" + core_ex + "\n" + after_ex))

    return {
        "before": before_ex,
        "core": core_ex,
        "after": after_ex,
        "core_hash": core_hash,
        "window_hash": window_hash,
    }


def make_id(*, smell: str, path: str, core_hash: str) -> str:
    raw = f"sniff:v1|{smell}|{path}|{core_hash}"
    return f"sniff:v1:{sha1_hex(raw)[:12]}"


def ensure_sniff_dir(repo_root: Path) -> Path:
    out = repo_root / ".sniff"
    out.mkdir(parents=True, exist_ok=True)
    return out


def git_ls_files(repo_root: Path) -> list[str]:
    proc = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=str(repo_root),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.decode("utf-8", errors="replace").strip() or "git ls-files failed")
    out = proc.stdout.decode("utf-8", errors="replace")
    paths = [p for p in out.split("\x00") if p]
    paths.sort()
    return paths


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8", errors="replace").splitlines(keepends=True)


def iter_ledger(path: Path) -> Iterable[dict[str, Any]]:
    if not path.exists():
        return []
    out: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            out.append(json.loads(s))
    return out


def latest_by_id(records: Iterable[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    latest: dict[str, dict[str, Any]] = {}
    for rec in records:
        rid = rec.get("id")
        if not isinstance(rid, str) or not rid:
            continue
        prev = latest.get(rid)
        if prev is None:
            latest[rid] = rec
            continue
        pu = str(prev.get("updated_at", ""))
        ru = str(rec.get("updated_at", ""))
        if ru >= pu:
            latest[rid] = rec
    return latest


def append_ledger(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, sort_keys=True) + "\n")


def write_index(sniff_dir: Path, records: dict[str, dict[str, Any]]) -> None:
    items = list(records.values())

    def key(r: dict[str, Any]) -> tuple:
        rr = r.get("range") or {}
        start = rr.get("start") if isinstance(rr, dict) else None
        try:
            start_i = int(start)
        except Exception:
            start_i = 0
        return (
            str(r.get("group", "")),
            str(r.get("smell", "")),
            str(r.get("path", "")),
            start_i,
            str(r.get("id", "")),
        )

    items.sort(key=key)

    index = {
        "generated_at": utcnow_iso(),
        "counts": {
            "total": len(items),
            "active": sum(1 for r in items if r.get("status") == "active"),
            "stale": sum(1 for r in items if r.get("status") == "stale"),
            "missing": sum(1 for r in items if r.get("status") == "missing"),
        },
        "findings": items,
    }

    (sniff_dir / "index.json").write_text(json.dumps(index, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_state(sniff_dir: Path, state: dict[str, Any]) -> None:
    (sniff_dir / "state.json").write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def repo_root_from_env() -> Path:
    root = os.environ.get("NUCK_ROOT") or os.environ.get("GIT_ROOT")
    if root:
        return Path(root)
    return Path.cwd()
