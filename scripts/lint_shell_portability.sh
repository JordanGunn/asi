#!/usr/bin/env sh
set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

search() {
  pattern="$1"
  dir="$2"

  if command -v rg >/dev/null 2>&1; then
    rg -n --color never --no-heading --with-filename --line-number --sort path "$pattern" "$dir" || true
  else
    # Fallback: grep (best-effort, may be slower)
    grep -RIn "$pattern" "$dir" 2>/dev/null || true
  fi
}

failed=0

hits="$(search 'head -n -1' "$root_dir/skills")"
if [ -n "$hits" ]; then
  echo "FAIL: Found GNU-only usage: head -n -1" >&2
  echo "$hits" >&2
  failed=1
fi

hits="$(search 'sha256sum .*\\| cut -d' "$root_dir/skills")"
if [ -n "$hits" ]; then
  echo "FAIL: Found non-portable sha256 parsing (use a helper like sha256_file)" >&2
  echo "$hits" >&2
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "OK: shell portability lint passed"
