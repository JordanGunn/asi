#!/bin/bash
set -e

# md-index: Generate .INDEX.md from split docs

show_help() {
    echo "Usage: index.sh --dir <path> [options]"
    echo ""
    echo "Options:"
    echo "  --dir <path>     Directory containing split docs (Required)"
    echo "  --out <path>     Output path for index (Default: <dir>/.INDEX.md)"
    exit 0
}

DIR=""
OUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dir) DIR="$2"; shift ;;
        --out) OUT_FILE="$2"; shift ;;
        --help) show_help ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$DIR" ]]; then
    echo "Error: --dir is required"
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' not found"
    exit 1
fi

if [[ -z "$OUT_FILE" ]]; then
    OUT_FILE="$DIR/.INDEX.md"
fi

echo "# Index" > "$OUT_FILE"
echo "" >> "$OUT_FILE"

# Find files matching NN_*.md, excluding .INDEX.md and .SUMMARY.md
# Sort by filename
FILES=$(ls "$DIR" | grep -E "^[0-9][0-9]_.+\.md$" | sort)

for f in $FILES; do
    # Read first H1 title
    TITLE=$(grep -m 1 "^# " "$DIR/$f" | sed 's/^# //')
    if [[ -z "$TITLE" ]]; then
        TITLE="$f" # Fallback to filename
    fi
    echo "- [$TITLE]($f)" >> "$OUT_FILE"
done

echo "Index generated at: $OUT_FILE"
