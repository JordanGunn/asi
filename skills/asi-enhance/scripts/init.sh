#!/usr/bin/env bash
set -euo pipefail

skill_path=""
out_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill-path)
      skill_path="$2"
      shift 2
      ;;
    --out-dir)
      out_dir="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: init.sh --skill-path <path> [--out-dir <dir>]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$skill_path" ]]; then
  echo "Missing --skill-path" >&2
  exit 2
fi

if [[ ! -d "$skill_path" ]]; then
  echo "Skill path not found: $skill_path" >&2
  exit 1
fi

if [[ ! -f "$skill_path/SKILL.md" ]]; then
  echo "SKILL.md not found in: $skill_path" >&2
  exit 1
fi

skill_path="$(cd "$skill_path" && pwd)"
if [[ -z "$out_dir" ]]; then
  out_dir="${skill_path}/.asi/enhance"
fi

mkdir -p "$out_dir"

now_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat <<JSON > "$out_dir/STATE.json"
{
  "skill_path": "${skill_path}",
  "out_dir": "${out_dir}",
  "initialized_at": "${now_utc}"
}
JSON

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_dir="${script_dir}/../assets/templates"

if [[ -d "$template_dir" ]]; then
  for template in ENHANCEMENT_REPORT.template.md CHANGELOG_ENTRY.template.md; do
    src="$template_dir/$template"
    if [[ -f "$src" ]]; then
      dest_name="${template/.template/}"
      dest="$out_dir/$dest_name"
      if [[ ! -f "$dest" ]]; then
        cp "$src" "$dest"
      fi
    fi
  done
fi

echo "Initialized enhancement workspace in: $out_dir"
