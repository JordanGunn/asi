from __future__ import annotations

from pathlib import Path

from asi.util.jsonio import write_json
from asi.util.paths import repo_root, ensure_dir


def migrate_legacy(*, force: bool = False) -> dict:
    root = repo_root()
    legacy_root = root / ".asi"
    creator_root = legacy_root / "creator"
    ensure_dir(creator_root)

    mapping = {
        "kickoff": legacy_root / "kickoff",
        "plan": legacy_root / "plan",
        "exec": legacy_root / "exec",
    }

    results = {"migrated": [], "skipped": [], "errors": []}

    for name, src in mapping.items():
        if not src.exists():
            results["skipped"].append({"phase": name, "reason": "missing"})
            continue
        dest = creator_root / name
        ensure_dir(dest)
        for path in src.rglob("*"):
            if path.is_dir():
                continue
            rel = path.relative_to(src)
            target = dest / rel
            if target.exists() and not force:
                results["skipped"].append(
                    {"phase": name, "path": str(rel), "reason": "exists"}
                )
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(path.read_bytes())
            results["migrated"].append({"phase": name, "path": str(rel)})

    report_path = creator_root / "migration_report.json"
    write_json(report_path, results)
    results["report"] = str(report_path)
    return results
