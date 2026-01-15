#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"

usage() {
    echo "usage: $0 [--fresh-start] --check {session|treatment}" >&2
}

check_path_exists() {
    local rel="$1"

    if [[ -f "$REPO_ROOT/$rel" ]]; then
        return 0
    fi

    if [[ -f "$SKILL_DIR/$rel" ]]; then
        return 0
    fi

    return 1
}

check_session_active() {
    local rel=".doctor/session.yaml"
    local path=""

    if [[ -f "$REPO_ROOT/$rel" ]]; then
        path="$REPO_ROOT/$rel"
    elif [[ -f "$SKILL_DIR/$rel" ]]; then
        path="$SKILL_DIR/$rel"
    else
        return 1
    fi

    # A session is considered active only if it is not already treated/abandoned.
    # Keep this check deterministic and lightweight.
    if grep -Eq '^status:[[:space:]]*(treated|abandoned)[[:space:]]*$' "$path"; then
        return 1
    fi

    return 0
}

is_fresh_start() {
    if [[ "${DOCTOR_FRESH_START:-}" == "1" ]]; then
        return 0
    fi

    for a in "$@"; do
        if [[ "$a" == "--fresh-start" ]]; then
            return 0
        fi
    done

    return 1
}

if is_fresh_start "$@"; then
    # Deterministic override: force router to treat invocation as a fresh start.
    # Any check will fail so that the router falls back to the default route.
    exit 1
fi

if [[ "${1:-}" == "--fresh-start" ]]; then
    shift
fi

if [[ "${1:-}" != "--check" ]]; then
    usage
    exit 2
fi

case "${2:-}" in
    session)
        check_session_active
        ;;
    treatment)
        check_path_exists ".doctor/treatment.md"
        ;;
    *)
        usage
        exit 2
        ;;
esac
