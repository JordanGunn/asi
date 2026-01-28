#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime, timezone


def iso_utc(ts: float) -> str:
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_frontmatter(lines):
    name = None
    description = None
    if not lines or not lines[0].strip() == "---":
        return name, description
    try:
        end = lines[1:].index("---\n") + 1
    except ValueError:
        try:
            end = lines[1:].index("---") + 1
        except ValueError:
            return name, description
    for line in lines[1:end]:
        if line.strip().startswith("name:") and name is None:
            name = line.split(":", 1)[1].strip()
        if line.strip().startswith("description:") and description is None:
            description = line.split(":", 1)[1].strip()
    return name, description


def main():
    parser = argparse.ArgumentParser(description="Scan a skill directory and produce inventory.")
    parser.add_argument("--skill-path", required=True)
    parser.add_argument("--out-dir", default=None)
    args = parser.parse_args()

    skill_path = os.path.abspath(args.skill_path)
    out_dir = args.out_dir or os.path.join(skill_path, ".asi", "enhance")
    out_dir = os.path.abspath(out_dir)

    if not os.path.isdir(skill_path):
        raise SystemExit(f"Skill path not found: {skill_path}")

    skill_md = os.path.join(skill_path, "SKILL.md")
    if not os.path.isfile(skill_md):
        raise SystemExit(f"SKILL.md not found in: {skill_path}")

    os.makedirs(out_dir, exist_ok=True)

    file_entries = []
    total_size = 0
    for root, _, files in os.walk(skill_path):
        for fname in files:
            fpath = os.path.join(root, fname)
            rel = os.path.relpath(fpath, skill_path)
            try:
                stat = os.stat(fpath)
            except OSError:
                continue
            size = stat.st_size
            total_size += size
            file_entries.append(
                {
                    "path": rel,
                    "size_bytes": size,
                    "modified_at": iso_utc(stat.st_mtime),
                }
            )

    file_entries.sort(key=lambda x: x["path"])

    with open(skill_md, "r", encoding="utf-8") as fh:
        lines = fh.readlines()

    name, description = parse_frontmatter(lines)
    todo_found = any("TODO" in line for line in lines)

    dirs_present = {
        "assets": os.path.isdir(os.path.join(skill_path, "assets")),
        "scripts": os.path.isdir(os.path.join(skill_path, "scripts")),
        "references": os.path.isdir(os.path.join(skill_path, "references")),
    }

    issues = []
    if not name:
        issues.append("SKILL.md missing frontmatter name")
    if not description:
        issues.append("SKILL.md missing frontmatter description")
    if todo_found:
        issues.append("SKILL.md contains TODO markers")
    if not dirs_present["references"]:
        issues.append("references/ directory missing")
    if not dirs_present["scripts"]:
        issues.append("scripts/ directory missing")
    if not dirs_present["assets"]:
        issues.append("assets/ directory missing")

    inventory = {
        "skill_path": skill_path,
        "generated_at": iso_utc(datetime.now(tz=timezone.utc).timestamp()),
        "files": file_entries,
        "file_count": len(file_entries),
        "total_size_bytes": total_size,
        "skill_name": name,
        "skill_description": description,
        "dirs_present": dirs_present,
        "issues": issues,
    }

    inventory_path = os.path.join(out_dir, "INVENTORY.json")
    with open(inventory_path, "w", encoding="utf-8") as fh:
        json.dump(inventory, fh, indent=2)

    scan_md_path = os.path.join(out_dir, "SCAN.md")
    with open(scan_md_path, "w", encoding="utf-8") as fh:
        fh.write("# Skill Scan\n\n")
        fh.write(f"Skill path: `{skill_path}`\n\n")
        fh.write(f"File count: {len(file_entries)}\n")
        fh.write(f"Total size (bytes): {total_size}\n\n")
        fh.write("## Directories\n\n")
        for key, val in dirs_present.items():
            fh.write(f"- {key}: {'present' if val else 'missing'}\n")
        fh.write("\n## Frontmatter\n\n")
        fh.write(f"- name: {name or 'missing'}\n")
        fh.write(f"- description: {description or 'missing'}\n")
        fh.write(f"- TODO markers: {'yes' if todo_found else 'no'}\n")
        fh.write("\n## Issues\n\n")
        if issues:
            for issue in issues:
                fh.write(f"- {issue}\n")
        else:
            fh.write("- none\n")

    print(f"Wrote {inventory_path}")
    print(f"Wrote {scan_md_path}")


if __name__ == "__main__":
    main()
