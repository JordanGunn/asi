#!/usr/bin/env sh
set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
arg="${1:-}"

usage() {
  cat <<'EOF'
Usage: scripts/lint_markdown.sh [--help] [--fix]

Runs a lightweight Markdown lint if available; otherwise performs minimal checks
(currently: ensures all Markdown files end with a trailing newline).

Default behavior is read-only. Passing --fix may modify files.
EOF
}

if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
  usage
  exit 0
fi

fix="$arg"

mdlint_cmd=""
if command -v markdownlint >/dev/null 2>&1; then
  mdlint_cmd="markdownlint"
elif command -v markdownlint-cli2 >/dev/null 2>&1; then
  mdlint_cmd="markdownlint-cli2"
fi

if [ -n "$mdlint_cmd" ]; then
  if [ "$fix" = "--fix" ]; then
    "$mdlint_cmd" --fix "$root_dir"
  else
    "$mdlint_cmd" "$root_dir"
  fi
else
  echo "Note: markdown lint tool not found; running minimal checks." >&2
fi

failed=0
for f in $(find "$root_dir" -type f -name '*.md' -print); do
  if [ -n "$(tail -c 1 "$f" | tr -d '\n')" ]; then
    echo "Missing trailing newline: ${f#"$root_dir/"}" >&2
    failed=1
    if [ "$fix" = "--fix" ]; then
      printf '\n' >>"$f"
      failed=0
    fi
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "OK: markdown lint checks passed"
