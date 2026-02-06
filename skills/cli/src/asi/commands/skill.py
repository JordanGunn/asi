from __future__ import annotations

from pathlib import Path


def _read_description(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines()[:20]:
        if line.startswith("description:"):
            return line.split("description:", 1)[1].strip()
    return ""


def emit_references(skill_dir: Path) -> None:
    refs_dir = skill_dir / "references"
    files = sorted(refs_dir.glob("[0-9][0-9]_*.md"))
    files = [f for f in files if f.name != "00_ROUTER.md"]

    print("# References")
    print("")
    for idx, f in enumerate(files, start=1):
        name = f.stem.split("_", 1)[-1]
        desc = _read_description(f)
        if desc:
            print(f"{idx}. **{name}** — {desc}")
        else:
            print(f"{idx}. **{name}**")
    print("")
    print("---")
    print("")

    for f in files:
        print(f.read_text(encoding="utf-8"))
        print("")
