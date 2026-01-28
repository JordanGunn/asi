#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  phase-helper.sh ensure-plan --definition <path> --plan <path> --progress <path>
  phase-helper.sh next-task --plan <path> --progress <path> --task <id> [--output <path>]
  phase-helper.sh current-task --progress <path> [--output <path>]

Actions:
  ensure-plan   Render the phased plan and initialize the tracker.
  next-task     Mark the task as done and print the next task context.
  current-task  Print the current task context without updating progress.
EOF
  exit 2
}

ensure_plan() {
  local definition plan progress
  definition="$1"
  plan="$2"
  progress="$3"
  python3 "$script_dir/generate_plan.py" --definition "$definition" --output "$plan" --progress "$progress"
}

next_task() {
  local plan progress task output response
  plan="$1"
  progress="$2"
  task="$3"
  output="$4"

  response="$(python3 "$script_dir/update_phase_progress.py" --progress "$progress" --task "$task")"
  if [[ -n "${output:-}" ]]; then
    mkdir -p "$(dirname "$output")"
    printf '%s\n' "$response" > "$output"
  fi

  python3 - <<'PY' "$response"
import json, sys
data = json.loads(sys.argv[1])
next_task = data.get("next_task")
if not next_task:
    print("phase-helper: no next task remains.")
    sys.exit(0)
print(f"phase-helper: next task {next_task['id']} ({next_task['phase']}) - {next_task.get('summary') or next_task.get('description')}")
print("Commands:", *next_task.get("commands", []))
print("Verification:", *next_task.get("verification", []))
PY
}

current_task() {
  local progress output response
  progress="$1"
  output="$2"

  response="$(python3 - <<'PY' "$progress"
import json, sys
progress_path = sys.argv[1]
with open(progress_path, "r", encoding="utf-8") as fh:
    progress = json.load(fh)
phase_index = progress.get("phase_index")
task_index = progress.get("task_index")
payload = { "phase_progress": progress }
current = None
if phase_index is not None and task_index is not None and phase_index >= 0 and task_index >= 0:
    phases = progress.get("phases", [])
    if phase_index < len(phases):
        phase = phases[phase_index]
        tasks = phase.get("tasks", [])
        if task_index < len(tasks):
            task = tasks[task_index]
            current = {
                "id": task.get("id"),
                "summary": task.get("summary"),
                "description": task.get("description"),
                "commands": task.get("commands", []),
                "verification": task.get("verification", []),
                "phase": phase.get("name"),
                "phase_summary": phase.get("summary"),
                "phase_index": phase_index,
                "task_index": task_index,
            }
payload["current_task"] = current
print(json.dumps(payload, indent=2))
PY
  )"

  if [[ -n "${output:-}" ]]; then
    mkdir -p "$(dirname "$output")"
    printf '%s\n' "$response" > "$output"
  fi

  python3 - <<'PY' "$response"
import json, sys
data = json.loads(sys.argv[1])
current = data.get("current_task")
if not current:
    print("phase-helper: no current task is marked as active.")
    sys.exit(0)
print(f"phase-helper: current task {current['id']} ({current['phase']}) - {current.get('summary') or current.get('description')}")
print("Commands:", *current.get("commands", []))
print("Verification:", *current.get("verification", []))
PY
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
  fi
  action="$1"
  shift
  case "$action" in
    ensure-plan)
      definition=""
      plan=""
      progress=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --definition)
            definition="$2"
            shift 2
            ;;
          --plan)
            plan="$2"
            shift 2
            ;;
          --progress)
            progress="$2"
            shift 2
            ;;
          *)
            echo "Unknown arg to ensure-plan: $1" >&2
            usage
            ;;
        esac
      done
      if [[ -z "$definition" || -z "$plan" || -z "$progress" ]]; then
        usage
      fi
      ensure_plan "$definition" "$plan" "$progress"
      ;;
    next-task)
      plan=""
      progress=""
      task=""
      output=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --plan)
            plan="$2"
            shift 2
            ;;
          --progress)
            progress="$2"
            shift 2
            ;;
          --task)
            task="$2"
            shift 2
            ;;
          --output)
            output="$2"
            shift 2
            ;;
          *)
            echo "Unknown arg to next-task: $1" >&2
            usage
            ;;
        esac
      done
      if [[ -z "$plan" || -z "$progress" || -z "$task" ]]; then
        usage
      fi
      next_task "$plan" "$progress" "$task" "$output"
      ;;
    current-task)
      progress=""
      output=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --progress)
            progress="$2"
            shift 2
            ;;
          --output)
            output="$2"
            shift 2
            ;;
          *)
            echo "Unknown arg to current-task: $1" >&2
            usage
            ;;
        esac
      done
      if [[ -z "$progress" ]]; then
        usage
      fi
      current_task "$progress" "$output"
      ;;
    *)
      echo "Unknown action: $action" >&2
      usage
      ;;
  esac
}

main "$@"
