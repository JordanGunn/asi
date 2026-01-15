from __future__ import annotations

import fnmatch
import json
from pathlib import Path
from typing import Any

from sniff_common import Range, ensure_sniff_dir, iter_ledger, latest_by_id, make_anchor, read_lines, utcnow_iso, write_index


def _matches_filters(rec: dict[str, Any], *, smell: str | None, group: str | None, path_glob: str | None, include_all: bool) -> bool:
    if not include_all and rec.get("status") != "active":
        return False
    if smell and str(rec.get("smell")) != smell:
        return False
    if group and str(rec.get("group")) != group:
        return False
    if path_glob and not fnmatch.fnmatch(str(rec.get("path")), path_glob):
        return False
    return True


def list_findings(repo_root: Path, *, smell: str | None = None, group: str | None = None, path_glob: str | None = None, include_all: bool = False) -> list[dict[str, Any]]:
    sniff_dir = ensure_sniff_dir(repo_root)
    ledger_path = sniff_dir / "findings.jsonl"
    latest = latest_by_id(iter_ledger(ledger_path))

    out = [r for r in latest.values() if _matches_filters(r, smell=smell, group=group, path_glob=path_glob, include_all=include_all)]

    def key(r: dict[str, Any]) -> tuple:
        rr = r.get("range") or {}
        start = rr.get("start") if isinstance(rr, dict) else None
        try:
            start_i = int(start)
        except Exception:
            start_i = 0
        return (str(r.get("group", "")), str(r.get("smell", "")), str(r.get("path", "")), start_i, str(r.get("id", "")))

    out.sort(key=key)
    return out


def validate_findings(repo_root: Path, *, reanchor: bool = False, include_all: bool = False) -> dict[str, int]:
    sniff_dir = ensure_sniff_dir(repo_root)
    ledger_path = sniff_dir / "findings.jsonl"

    latest = latest_by_id(iter_ledger(ledger_path))
    now = utcnow_iso()

    counts = {"active": 0, "stale": 0, "missing": 0, "updated": 0}

    for rid, rec in sorted(latest.items(), key=lambda kv: kv[0]):
        status0 = rec.get("status")
        if not include_all:
            if reanchor:
                if status0 not in {"stale", "missing"}:
                    continue
            else:
                if status0 != "active":
                    continue
        path = repo_root / str(rec.get("path"))
        rr = rec.get("range") if isinstance(rec.get("range"), dict) else {}
        try:
            start = int(rr.get("start"))
            end = int(rr.get("end"))
        except Exception:
            start, end = 1, 1

        if not path.exists():
            status = "missing"
            if status != rec.get("status"):
                _append_update(sniff_dir, rec, now, status=status)
                counts["updated"] += 1
            counts[status] += 1
            continue

        lines = read_lines(path)
        anchor_now = make_anchor(lines, Range(start=start, end=min(end, len(lines))))
        stored = rec.get("anchor") if isinstance(rec.get("anchor"), dict) else {}

        if anchor_now.get("core_hash") == stored.get("core_hash"):
            status = "active"
            if status != rec.get("status"):
                _append_update(sniff_dir, rec, now, status=status, range_={"start": start, "end": end}, anchor=anchor_now)
                counts["updated"] += 1
            counts[status] += 1
            continue

        if reanchor:
            updated = _try_reanchor(repo_root, rec)
            if updated:
                _append_update(sniff_dir, rec, now, **updated)
                counts["updated"] += 1
                counts["active"] += 1
                continue

        status = "stale"
        if status != rec.get("status"):
            _append_update(sniff_dir, rec, now, status=status)
            counts["updated"] += 1
        counts[status] += 1

    latest2 = latest_by_id(iter_ledger(ledger_path))
    write_index(sniff_dir, latest2)
    return counts


def _append_update(sniff_dir: Path, prev: dict[str, Any], now: str, **updates: Any) -> None:
    rec = dict(prev)
    rec.update(updates)
    rec["updated_at"] = now
    # preserve created_at
    if "created_at" not in rec:
        rec["created_at"] = prev.get("created_at") or now

    ledger_path = sniff_dir / "findings.jsonl"
    from sniff_common import append_ledger

    append_ledger(ledger_path, rec)


def _try_reanchor(repo_root: Path, rec: dict[str, Any]) -> dict[str, Any] | None:
    path = repo_root / str(rec.get("path"))
    if not path.exists():
        return None

    stored_anchor = rec.get("anchor") if isinstance(rec.get("anchor"), dict) else {}
    needle = str(stored_anchor.get("core", ""))
    if not needle:
        return None

    rr = rec.get("range") if isinstance(rec.get("range"), dict) else {}
    try:
        span = int((rr.get("end") or 1)) - int((rr.get("start") or 1)) + 1
    except Exception:
        span = 1

    lines = read_lines(path)

    # normalize per-line while preserving mapping
    from sniff_common import normalize

    norm_lines: list[str] = []
    mapping: list[int] = []
    for i, line in enumerate(lines, start=1):
        nl = normalize(line)
        if not nl:
            continue
        norm_lines.append(nl)
        mapping.append(i)

    norm_text = "\n".join(norm_lines)
    needle120 = needle[:120]
    if not needle120:
        return None

    idx = 0
    candidates: list[int] = []
    while True:
        j = norm_text.find(needle120, idx)
        if j < 0:
            break
        # estimate candidate line by counting newlines before j
        line_idx = norm_text[:j].count("\n")
        if 0 <= line_idx < len(mapping):
            candidates.append(mapping[line_idx])
        idx = j + 1

    # stable order
    seen = set()
    uniq: list[int] = []
    for c in candidates:
        if c not in seen:
            seen.add(c)
            uniq.append(c)

    for start in uniq:
        for delta in range(-5, 6):
            s = max(1, start + delta)
            e = min(len(lines), s + span - 1)
            anchor_now = make_anchor(lines, Range(start=s, end=e))
            if anchor_now.get("core_hash") == stored_anchor.get("core_hash") or anchor_now.get("window_hash") == stored_anchor.get("window_hash"):
                return {"status": "active", "range": {"start": s, "end": e}, "anchor": anchor_now}

    return None


def format_human(rows: list[dict[str, Any]]) -> str:
    out: list[str] = []
    for r in rows:
        rr = r.get("range") if isinstance(r.get("range"), dict) else {}
        out.append(
            f"{r.get('id')}\t{r.get('status')}\t{r.get('group')}\t{r.get('smell')}\t{r.get('path')}:{rr.get('start')}-{rr.get('end')}"
        )
    return "\n".join(out) + ("\n" if out else "")


def format_json(rows: list[dict[str, Any]]) -> str:
    return json.dumps(rows, indent=2, sort_keys=True) + "\n"
