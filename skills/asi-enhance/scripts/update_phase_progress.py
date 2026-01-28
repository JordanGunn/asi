#!/usr/bin/env python3
import argparse
import json
import os
import sys


def load_path(path):
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def save_path(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)


def find_task(progress, task_id):
    for phase_idx, phase in enumerate(progress.get("phases", [])):
        for task_idx, task in enumerate(phase.get("tasks", [])):
            if task.get("id") == task_id:
                return phase_idx, task_idx
    return None, None


def flatten(progress):
    entries = []
    for phase_idx, phase in enumerate(progress.get("phases", [])):
        for task_idx, task in enumerate(phase.get("tasks", [])):
            entries.append((phase_idx, task_idx, phase, task))
    return entries


def compute_next(progress, completed_index):
    flat = flatten(progress)
    if completed_index is None:
        return None
    for idx, (p_idx, t_idx, _, _) in enumerate(flat):
        if (p_idx, t_idx) == completed_index:
            next_idx = idx + 1
            break
    else:
        return None
    if next_idx >= len(flat):
        return None
    return flat[next_idx][0], flat[next_idx][1]


def apply_status(progress, completed, next_idx):
    for phase_idx, phase in enumerate(progress.get("phases", [])):
        for task_idx, task in enumerate(phase.get("tasks", [])):
            if completed and (phase_idx, task_idx) <= completed:
                task["status"] = "completed"
            elif next_idx and (phase_idx, task_idx) == next_idx:
                task["status"] = "current"
            else:
                if task["status"] != "completed":
                    task["status"] = "pending"
    if next_idx:
        progress["phase_index"] = next_idx[0]
        progress["task_index"] = next_idx[1]
    else:
        progress["phase_index"] = -1
        progress["task_index"] = -1
    progress["last_completed"] = {"phase": completed[0], "task": completed[1]} if completed else None


def next_task_payload(progress, next_idx):
    if not next_idx:
        return None
    phase = progress["phases"][next_idx[0]]
    task = phase["tasks"][next_idx[1]]
    return {
        "id": task.get("id"),
        "summary": task.get("summary"),
        "description": task.get("description"),
        "commands": task.get("commands", []),
        "verification": task.get("verification", []),
        "phase": phase.get("name"),
        "phase_summary": phase.get("summary"),
        "phase_index": next_idx[0],
        "task_index": next_idx[1],
    }


def main():
    parser = argparse.ArgumentParser(description="Update phase progress and print next task context.")
    parser.add_argument("--progress", required=True)
    parser.add_argument("--task", required=True)
    args = parser.parse_args()

    progress = load_path(args.progress)
    completed = find_task(progress, args.task)
    if completed == (None, None):
        sys.exit(f"ERROR: task {args.task} not found.")

    next_idx = compute_next(progress, completed)
    apply_status(progress, completed, next_idx)
    save_path(args.progress, progress)

    payload = {
        "next_task": next_task_payload(progress, next_idx),
        "phase_progress": progress,
    }
    print(json.dumps(payload, indent=2))


if __name__ == "__main__":
    main()
