#!/usr/bin/env sh
set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/check_structure.sh [--help]

Verifies the repository structure required by this ASI specification.

This script is read-only and exits non-zero on failure.
EOF
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

require_path() {
  path="$1"
  if [ ! -e "$root_dir/$path" ]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
}

require_dir() {
  path="$1"
  if [ ! -d "$root_dir/$path" ]; then
    echo "Missing required directory: $path" >&2
    exit 1
  fi
}

require_file() {
  path="$1"
  if [ ! -f "$root_dir/$path" ]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
}

require_file "README.md"
require_file "LICENSE"
require_file "CONTRIBUTING.md"
require_file "CODE_OF_CONDUCT.md"

require_dir "docs"
require_dir "docs/spec"
require_dir "docs/examples"
require_dir "references"
require_dir "scripts"
require_dir "assets/templates"

require_file "docs/manifesto/.INDEX.md"
require_file "docs/spec/.INDEX.md"
require_file "docs/spec/rfc-001/.INDEX.md"
require_file "docs/spec/rfc-002/.INDEX.md"
require_file "docs/spec/rfc-003/.INDEX.md"
require_file "docs/glossary.md"
require_file "docs/faq.md"
require_file "docs/changelog.md"
require_file "docs/examples/example-01-surface-reduction.md"
require_file "docs/examples/example-02-passive-behavior.md"
require_file "docs/examples/example-03-failure-semantics.md"
require_file "docs/patterns/.INDEX.md"
require_file "docs/patterns/skill-contract/.INDEX.md"

require_file "references/.INDEX.md"
require_file "references/01_SUMMARY.md"
require_file "references/02_INVARIANTS.md"
require_file "references/03_NON_GOALS.md"
require_file "references/04_PASSIVE_CONTRACT.md"
require_file "references/05_DETERMINISM_ORDERING.md"
require_file "references/06_ASI_MCP_SEPARATION.md"
require_file "references/07_FAILURE_SEMANTICS.md"
require_file "references/08_CONFORMANCE_CHECKLIST.md"
require_file "references/09_ANTI_PATTERNS.md"
require_file "references/10_EXAMPLES_GUIDE.md"

require_file "scripts/check_structure.sh"
require_file "scripts/lint_markdown.sh"
require_file "scripts/README.md"
require_file "assets/templates/rfc-template.md"
require_file "assets/templates/example-template.md"

bad_refs="$(find "$root_dir/references" -maxdepth 1 -type f -name '*.md' ! -name '.INDEX.md' ! -regex '.*/[0-9][0-9]_[^/].*\.md' -print || true)"
if [ -n "$bad_refs" ]; then
  echo "Reference files must match NN_*.md naming:" >&2
  echo "$bad_refs" >&2
  exit 1
fi

ref_numbers="$(find "$root_dir/references" -maxdepth 1 -type f -name '*.md' ! -name '.INDEX.md' -print | while IFS= read -r f; do basename "$f"; done | cut -c1-2 | sort -u)"
expected_numbers="01
02
03
04
05
06
07
08
09
10"
if [ "$ref_numbers" != "$expected_numbers" ]; then
  echo "Reference files must cover 01..10 exactly (no gaps/dupes)." >&2
  echo "Found:" >&2
  printf '%s\n' "$ref_numbers" >&2
  exit 1
fi

echo "OK: structure checks passed"
