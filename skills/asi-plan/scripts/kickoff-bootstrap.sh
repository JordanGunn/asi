#!/usr/bin/env bash
set -euo pipefail

# asi-plan kickoff-phase bootstrap script
# Checks environment prerequisites and (optionally) installs deps with explicit opt-in.

usage() {
  cat <<'EOF'
Usage: scripts/kickoff-bootstrap.sh [--check] [--print-install] [--install --yes]

Default: --check

Checks:
  - bash available (running)
  - jq available (required for inject/validate)

Install behavior:
  - No installs happen unless --install --yes are both passed.
  - If a package manager is not detected, prints manual instructions.

Exit codes:
  0  OK
  1  Missing prerequisites / install failed
  2  Invalid arguments
EOF
  exit 2
}

mode="check"
yes=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      mode="check"
      shift
      ;;
    --print-install)
      mode="print-install"
      shift
      ;;
    --install)
      mode="install"
      shift
      ;;
    --yes)
      yes=true
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

os="$(uname -s 2>/dev/null || echo unknown)"

need_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "PASS: found $cmd"
    return 0
  fi
  echo "FAIL: missing $cmd${hint:+ ($hint)}" >&2
  return 1
}

print_install_instructions() {
  cat <<EOF
Install jq:
  macOS (Homebrew): brew install jq
  Debian/Ubuntu:    sudo apt-get update && sudo apt-get install -y jq
  Fedora:           sudo dnf install -y jq
  Arch:             sudo pacman -S --noconfirm jq

Then re-run:
  scripts/kickoff-bootstrap.sh --check
EOF
}

install_jq() {
  if command -v jq >/dev/null 2>&1; then
    echo "OK: jq already installed"
    return 0
  fi

  if [[ "$yes" != true ]]; then
    echo "Refusing to install without --yes" >&2
    print_install_instructions >&2
    return 2
  fi

  if [[ "$os" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    brew install jq
    return $?
  fi
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y jq
    return $?
  fi
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y jq
    return $?
  fi
  if command -v yum >/dev/null 2>&1; then
    sudo yum install -y jq
    return $?
  fi
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm jq
    return $?
  fi

  echo "No supported package manager detected; cannot auto-install jq." >&2
  print_install_instructions >&2
  return 1
}

echo "=== asi-plan kickoff bootstrap ==="
echo "OS: $os"

case "$mode" in
  check)
    failed=0
    need_cmd jq "required" || failed=1
    if [[ "$failed" -eq 0 ]]; then
      echo "=== bootstrap: OK ==="
      exit 0
    fi
    echo "=== bootstrap: FAILED ===" >&2
    echo "" >&2
    print_install_instructions >&2
    exit 1
    ;;
  print-install)
    print_install_instructions
    ;;
  install)
    install_jq
    ;;
  *)
    usage
    ;;
esac
