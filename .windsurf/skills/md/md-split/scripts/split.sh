#!/bin/bash
set -e

# md-split: Split a markdown file by H2 headings

show_help() {
    echo "Usage: split.sh --in <path> [options]"
    echo ""
    echo "Options:"
    echo "  --in <path>       Source markdown file to split (Required)"
    echo "  --out <dir>      Output directory (Default: same as input)"
    echo "  --prefix <NN>    Starting index for numbering (Default: 01)"
    echo "  --dry-run        Show what would be done without making changes"
    echo "  --force          Overwrite existing files"
    echo "  --no-intro       Skip creating 00_INTRO.md if content exists before first H2"
    echo "  --manifest       Generate .SPLIT.json manifest (Default: ON)"
    exit 0
}

# Defaults
IN_FILE=""
OUT_DIR=""
PREFIX="01"
DRY_RUN=false
FORCE=false
KEEP_INTRO=true
GEN_MANIFEST=true

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --in) IN_FILE="$2"; shift ;;
        --out) OUT_DIR="$2"; shift ;;
        --prefix) PREFIX="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
        --no-intro) KEEP_INTRO=false ;;
        --manifest) GEN_MANIFEST=true ;;
        --no-manifest) GEN_MANIFEST=false ;;
        --help) show_help ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$IN_FILE" ]]; then
    echo "Error: --in is required"
    exit 1
fi

if [[ ! -f "$IN_FILE" ]]; then
    echo "Error: Input file '$IN_FILE' not found"
    exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
    # Get filename without extension and lowercase it
    FILENAME=$(basename "$IN_FILE")
    BASE_NAME="${FILENAME%.*}"
    OUT_DIR_NAME=$(echo "$BASE_NAME" | tr '[:upper:]' '[:lower:]')
    OUT_DIR="$(dirname "$IN_FILE")/$OUT_DIR_NAME"
fi

mkdir -p "$OUT_DIR"

# Helper to slugify heading
slugify() {
    local title="$1"
    # Uppercase
    local slug=$(echo "$title" | tr '[:lower:]' '[:upper:]')
    # Spaces/dashes -> underscores
    slug=$(echo "$slug" | tr ' -' '__')
    # Strip punctuation except underscores
    slug=$(echo "$slug" | sed 's/[^A-Z0-9_]//g')
    # Collapse multiple underscores
    slug=$(echo "$slug" | sed 's/___*/_/g')
    # Trim underscores
    slug=$(echo "$slug" | sed 's/^_//;s/_$//')
    # Truncate
    echo "${slug:0:60}"
}

# Initial state
CURRENT_FILE=""
FILE_COUNT=0
GENERATED_FILES=()
MANIFEST_ENTRIES=()
BUFFER=""
INTRO_BUFFER=""
FIRST_H2_FOUND=false
INDEX=$((10#$PREFIX))

append_line() {
    # $1 = current buffer, $2 = line to append
    if [[ -z "$1" ]]; then
        printf "%s" "$2"
    else
        printf "%s\n%s" "$1" "$2"
    fi
}

intro_has_meaningful_content() {
    # Returns 0 (true) when intro has content beyond an initial H1 title + whitespace.
    # Returns 1 (false) when intro is effectively empty (whitespace) or title-only.
    awk '
        BEGIN { state=0 }
        {
            if (state==0) {
                if ($0 ~ /^[[:space:]]*$/) next
                if ($0 ~ /^#[[:space:]]/) { state=1; next }
                state=2
            }
            if (state==1) {
                if ($0 ~ /^[[:space:]]*$/) next
                state=2
            }
            if (state==2) {
                if ($0 !~ /^[[:space:]]*$/) { exit 0 }
            }
        }
        END { exit 1 }
    '
}

# Process file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ $line =~ ^##[[:space:]] ]]; then
        # New H2 section found
        H2_TITLE="${line#*## }"
        
        # Save previous section if it exists
        if [[ "$FIRST_H2_FOUND" == true ]]; then
            # We already have a CURRENT_FILE
            if [[ "$DRY_RUN" == false ]]; then
                if [[ -f "$CURRENT_PATH" && "$FORCE" == false ]]; then
                    echo "Error: File '$CURRENT_PATH' already exists. Use --force to overwrite."
                    exit 1
                fi
                printf "%s\n" "$BUFFER" > "$CURRENT_PATH"
            fi
            GENERATED_FILES+=("$CURRENT_FILENAME")
            MANIFEST_ENTRIES+=("{\"index\": $((INDEX-1)), \"filename\": \"$CURRENT_FILENAME\", \"title\": \"$CURRENT_TITLE\", \"source_heading\": \"## $CURRENT_TITLE\"}")
        else
            # This is the first H2. Handle intro.
            # Only write 00_INTRO.md if intro has meaningful content beyond title-only.
            if [[ "$KEEP_INTRO" == true && -n "$(printf "%s" "$INTRO_BUFFER" | tr -d '[:space:]')" ]]; then
                if printf "%s\n" "$INTRO_BUFFER" | intro_has_meaningful_content; then
                    INTRO_FILENAME="00_INTRO.md"
                    INTRO_PATH="$OUT_DIR/$INTRO_FILENAME"
                    if [[ "$DRY_RUN" == false ]]; then
                        if [[ -f "$INTRO_PATH" && "$FORCE" == false ]]; then
                            echo "Error: File '$INTRO_PATH' already exists. Use --force to overwrite."
                            exit 1
                        fi
                        printf "%s\n" "$INTRO_BUFFER" > "$INTRO_PATH"
                    fi
                    GENERATED_FILES+=("$INTRO_FILENAME")
                    MANIFEST_ENTRIES+=("{\"index\": 0, \"filename\": \"$INTRO_FILENAME\", \"title\": \"Intro\", \"source_heading\": null}")
                fi
            fi
            FIRST_H2_FOUND=true
        fi

        # Start new section
        SLUG=$(slugify "$H2_TITLE")
        NN=$(printf "%02d" $INDEX)
        CURRENT_FILENAME="${NN}_${SLUG}.md"
        CURRENT_PATH="$OUT_DIR/$CURRENT_FILENAME"
        CURRENT_TITLE="$H2_TITLE"
        BUFFER="# $H2_TITLE" # Promote H2 to H1
        INDEX=$((INDEX + 1))
        FILE_COUNT=$((FILE_COUNT + 1))
    else
        # Append to current buffer
        if [[ "$FIRST_H2_FOUND" == true ]]; then
            BUFFER="$(append_line "$BUFFER" "$line")"
        else
            INTRO_BUFFER="$(append_line "$INTRO_BUFFER" "$line")"
        fi
    fi
done < "$IN_FILE"

# Save last section
if [[ "$FIRST_H2_FOUND" == true ]]; then
    if [[ "$DRY_RUN" == false ]]; then
        if [[ -f "$CURRENT_PATH" && "$FORCE" == false ]]; then
            echo "Error: File '$CURRENT_PATH' already exists. Use --force to overwrite."
            exit 1
        fi
        printf "%s\n" "$BUFFER" > "$CURRENT_PATH"
    fi
    GENERATED_FILES+=("$CURRENT_FILENAME")
    MANIFEST_ENTRIES+=("{\"index\": $((INDEX-1)), \"filename\": \"$CURRENT_FILENAME\", \"title\": \"$CURRENT_TITLE\", \"source_heading\": \"## $CURRENT_TITLE\"}")
else
    # No H2 found at all. Handle intro/entire content.
    # Here we keep the full content (including any H1 title) if non-empty.
    if [[ "$KEEP_INTRO" == true && -n "$(printf "%s" "$INTRO_BUFFER" | tr -d '[:space:]')" ]]; then
        INTRO_FILENAME="00_INTRO.md"
        INTRO_PATH="$OUT_DIR/$INTRO_FILENAME"
        if [[ "$DRY_RUN" == false ]]; then
            if [[ -f "$INTRO_PATH" && "$FORCE" == false ]]; then
                echo "Error: File '$INTRO_PATH' already exists. Use --force to overwrite."
                exit 1
            fi
            printf "%s\n" "$INTRO_BUFFER" > "$INTRO_PATH"
        fi
        GENERATED_FILES+=("$INTRO_FILENAME")
        MANIFEST_ENTRIES+=("{\"index\": 0, \"filename\": \"$INTRO_FILENAME\", \"title\": \"Intro\", \"source_heading\": null}")
    fi
fi

# Generate manifest
if [[ "$GEN_MANIFEST" == true && "$DRY_RUN" == false ]]; then
    MANIFEST_PATH="$OUT_DIR/.SPLIT.json"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "{" > "$MANIFEST_PATH"
    echo "  \"version\": \"1.0\"," >> "$MANIFEST_PATH"
    echo "  \"input\": \"$IN_FILE\"," >> "$MANIFEST_PATH"
    echo "  \"output_dir\": \"$OUT_DIR\"," >> "$MANIFEST_PATH"
    echo "  \"created_at\": \"$TIMESTAMP\"," >> "$MANIFEST_PATH"
    echo "  \"rules\": {" >> "$MANIFEST_PATH"
    echo "    \"split_on\": \"h2\"," >> "$MANIFEST_PATH"
    echo "    \"promote_heading\": \"h2_to_h1\"," >> "$MANIFEST_PATH"
    echo "    \"naming\": \"<NN>_<NAME_UPPERCASE>.md\"," >> "$MANIFEST_PATH"
    echo "    \"intro_file\": \"00_INTRO.md\"" >> "$MANIFEST_PATH"
    echo "  }," >> "$MANIFEST_PATH"
    echo "  \"files\": [" >> "$MANIFEST_PATH"
    
    LEN=${#MANIFEST_ENTRIES[@]}
    for (( i=0; i<$LEN; i++ )); do
        echo "    ${MANIFEST_ENTRIES[$i]}$([[ $i -lt $((LEN-1)) ]] && echo ",")" >> "$MANIFEST_PATH"
    done
    
    echo "  ]" >> "$MANIFEST_PATH"
    echo "}" >> "$MANIFEST_PATH"
fi

# Summary
echo "Split complete."
echo "Input: $IN_FILE"
echo "Output: $OUT_DIR"
echo "Count: ${#GENERATED_FILES[@]}"
echo "Files:"
for f in "${GENERATED_FILES[@]}"; do
    echo "  - $f"
done
