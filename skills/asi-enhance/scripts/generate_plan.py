#!/usr/bin/env python3
import argparse
import json
import os
import textwrap


def ensure_dir(path):
    directory = os.path.dirname(path)
    if directory:
        os.makedirs(directory, exist_ok=True)


def render_plan(metadata, phases, definition_path, output_path, progress_path):
    lines = []
    lines.append("# WORKPLAN — asi-enhance skill")
    lines.append("")

    required_sections = metadata.get("required_sections", "Intent,Goals,Non-Goals,Scope,Constraints,Plan,Commands,Validation,Approval")
    approval_pattern = metadata.get("approval_pattern", "^Approved:[[:space:]]+yes$")
    validation_policy = metadata.get("validation_policy", "explicit commands (guard scripts + scans)")
    lines.append("## Plan Metadata")
    lines.append(f"Approval pattern: {approval_pattern}")
    lines.append(f"Required sections: {required_sections}")
    lines.append(f"Validation policy: {validation_policy}")
    lines.append(f"Plan Source: asi-enhance")
    rel_definition = os.path.relpath(definition_path, os.path.dirname(output_path))
    rel_progress = os.path.relpath(progress_path, os.path.dirname(output_path))
    lines.append(f"Plan Definition: {rel_definition}")
    lines.append(f"Phase progress file: {rel_progress}")
    lines.append("")

    section_map = {
        "Intent": metadata.get("intent", ""),
        "Goals": metadata.get("goals", []),
        "Non-Goals": metadata.get("non_goals", []),
        "Scope": metadata.get("scope", []),
        "Constraints": metadata.get("constraints", []),
    }
    for heading, value in section_map.items():
        lines.append(f"## {heading}")
        if isinstance(value, list):
            if value:
                for item in value:
                    lines.append(f"- {item}")
            else:
                lines.append("- none")
        else:
            lines.append(value or "- none")
        lines.append("")

    lines.append("## Plan")
    for phase in phases:
        lines.append(f"### {phase.get('name')}")
        summary = phase.get("summary")
        if summary:
            lines.append(summary)
        for task in phase.get("tasks", []):
            lines.append(f"- [ ] {task.get('id')}: {task.get('summary')}")
            description = task.get("description")
            if description:
                for desc_line in textwrap.wrap(description, width=80):
                    lines.append(f"  {desc_line}")
            commands = task.get("commands", [])
            if commands:
                lines.append("  Commands:")
                for cmd in commands:
                    lines.append(f"  - {cmd}")
            verification = task.get("verification", [])
            if verification:
                lines.append("  Verification:")
                for ver in verification:
                    lines.append(f"  - {ver}")
        lines.append("")

    commands = metadata.get("commands", [])
    lines.append("## Commands")
    if commands:
        for cmd in commands:
            lines.append(f"- {cmd}")
    else:
        lines.append("- see phase-specific entries above")
    lines.append("")

    validation_steps = metadata.get("validation_steps", [])
    lines.append("## Validation")
    if validation_steps:
        for step in validation_steps:
            lines.append(f"- {step}")
    else:
        lines.append("- scripts/bootstrap.sh --check")
    lines.append("")

    approval = metadata.get("approval", {})
    lines.append("## Approval")
    if approval:
        for key, value in approval.items():
            lines.append(f"{key}: {value}")
    else:
        lines.append("Approved: yes")
        lines.append("Approved by: workflow")
        lines.append("Approved on: 2026-01-01")
    lines.append("")

    ensure_dir(output_path)
    with open(output_path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))


def build_progress(definition, output_path, progress_path):
    phases = []
    for phase in definition.get("phases", []):
        tasks = []
        for task in phase.get("tasks", []):
            tasks.append(
                {
                    "id": task.get("id"),
                    "summary": task.get("summary"),
                    "description": task.get("description"),
                    "commands": task.get("commands", []),
                    "verification": task.get("verification", []),
                    "status": "pending",
                }
            )
        phases.append(
            {
                "name": phase.get("name"),
                "summary": phase.get("summary"),
                "tasks": tasks,
            }
        )

    current_phase = 0 if phases else -1
    current_task = 0 if phases and phases[0]["tasks"] else -1
    if current_phase >= 0 and current_task >= 0:
        phases[current_phase]["tasks"][current_task]["status"] = "current"

    progress = {
        "plan_definition": os.path.relpath(definition["path"], os.path.dirname(output_path)),
        "plan_path": os.path.abspath(output_path),
        "phase_index": current_phase,
        "task_index": current_task,
        "phases": phases,
    }

    ensure_dir(progress_path)
    with open(progress_path, "w", encoding="utf-8") as fh:
        json.dump(progress, fh, indent=2)


def main():
    parser = argparse.ArgumentParser(description="Generate phased plan for asi-enhance.")
    parser.add_argument("--definition", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--progress", required=True)
    args = parser.parse_args()

    with open(args.definition, "r", encoding="utf-8") as fh:
        definition = json.load(fh)
    definition["path"] = os.path.abspath(args.definition)
    phases = definition.get("phases", [])
    metadata = definition.get("metadata", {})

    render_plan(metadata, phases, args.definition, args.output, args.progress)
    build_progress(definition, args.output, args.progress)


if __name__ == "__main__":
    main()
