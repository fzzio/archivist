#!/bin/bash

# Function to display help menu
show_help() {
    echo "Usage: $0 [directories/files...] [options]"
    echo
    echo "Description:"
    echo "  This script processes files in specified directories or individual files,"
    echo "  concatenating their contents into a single file or copying them to the clipboard."
    echo "  It respects .gitignore if present and offers options to customize behavior."
    echo
    echo "Options:"
    echo "  -h, --help                       Show this help message"
    echo "  --clipboard                      Copy the result to clipboard instead of creating a file"
    echo "  --output <file>                  Specify a custom output file (default: files.txt)"
    echo "  --supported-binary-files <types> Specify additional supported binary file types (e.g., 'CSV|JSON')"
    echo "  --force-ignore <paths>           Specify additional paths to ignore (space-separated)"
    echo
    echo "Examples:"
    echo "  $0 /path/to/project1 /path/to/project2"
    echo "  $0 . src/file.js --clipboard --supported-binary-files 'CSV|JSON'"
    echo "  $0 /path/to/project --output result.md --force-ignore 'temp logs'"
}

# Initial configuration
OUTPUT_FILE="files.txt"
USE_CLIPBOARD=false
SUPPORTED_BINARY_TYPES=""
FORCE_IGNORE=()
PATHS_TO_PROCESS=()

# Default ignore list
DEFAULT_IGNORE=(
    ".git" ".svn" ".hg" ".DS_Store" "Thumbs.db" "desktop.ini"
    "node_modules" "dist" "build" "target" "out"
    "*.log" "*.tmp" "*.temp" "*.swp" "*.bak" "*~"
    "package-lock.json" "yarn.lock" ".gitignore" "README.md"
)

# Arrays to store processed and unprocessed file extensions
PROCESSED_EXTENSIONS=()
UNPROCESSED_EXTENSIONS=()
PROCESSED_COUNT=0
UNPROCESSED_COUNT=0

# Process arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        --clipboard) USE_CLIPBOARD=true; shift ;;
        --output) shift; OUTPUT_FILE="$1"; shift ;;
        --supported-binary-files) shift; SUPPORTED_BINARY_TYPES="$1"; shift ;;
        --force-ignore) shift; 
            while [[ "$#" -gt 0 && "$1" != --* ]]; do
                FORCE_IGNORE+=("$1")
                shift
            done
            ;;
        -*) echo "Unknown option: $1" >&2; show_help; exit 1 ;;
        *) PATHS_TO_PROCESS+=("$1"); shift ;;
    esac
done

# Function to check if a path should be ignored
should_ignore() {
    local path="$1"

    # Check against default ignore list
    for ignore in "${DEFAULT_IGNORE[@]}"; do
        if [[ "$path" == $ignore || "$path" == *"/$ignore"* ]]; then
            return 0
        fi
    done

    # Check against force ignore list
    for ignore in "${FORCE_IGNORE[@]}"; do
        if [[ "$path" == $ignore || "$path" == *"/$ignore"* ]]; then
            return 0
        fi
    done

    return 1
}

# Function to process a file
process_file() {
    local file="$1"
    local mime_type=$(file -b --mime-type "$file")
    local extension="${file##*.}"

    if should_ignore "$file"; then
        return
    fi

    echo "$file"
    echo '```'

    if [[ $mime_type == text/* || $extension =~ ^(ts|js|html|css|sass|scss|tsx|jsx|java|scala|vue|sql|json)$ || $SUPPORTED_BINARY_TYPES == *"$extension"* ]]; then
        cat "$file"
        PROCESSED_EXTENSIONS+=("$extension")
        ((PROCESSED_COUNT++))
    else
        echo "(Binary file, content not shown)"
        UNPROCESSED_EXTENSIONS+=("$extension")
        ((UNPROCESSED_COUNT++))
        echo "$file" >> unprocessed.log
    fi

    echo '```'
    echo
}

# Function to process a directory or file
process_path() {
    local path="$1"

    if [ ! -e "$path" ]; then
        echo "Error: $path does not exist"
        return
    fi

    if [ -d "$path" ]; then
        cd "$path" || return

        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if [ -f ".gitignore" ]; then
                echo "Not a Git repository, but .gitignore found in $path."
                read -p "Do you want to initialize a Git repository? (y/n): " init_repo
                if [[ $init_repo =~ ^[Yy]$ ]]; then
                    git init
                else
                    echo "Warning: Processing all files, including those in hidden folders."
                    read -p "Are you sure you want to continue? (y/n): " continue_processing
                    if [[ ! $continue_processing =~ ^[Yy]$ ]]; then
                        echo "Skipping $path"
                        cd - > /dev/null
                        return
                    fi
                fi
            fi
        fi

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git ls-tree -r HEAD --name-only | while read -r file; do
                process_file "$file"
            done
        else
            find . -type f | while read -r file; do
                process_file "$file"
            done
        fi

        cd - > /dev/null
    elif [ -f "$path" ]; then
        process_file "$path"
    fi
}

# Main processing
output=""
> unprocessed.log  # Clear the unprocessed.log file
for path in "${PATHS_TO_PROCESS[@]}"; do
    output+="$(process_path "$path")"
done

# Handle output
if [ "$USE_CLIPBOARD" = true ]; then
    echo "$output" | xclip -selection clipboard
    echo "Content has been copied to clipboard."
else
    echo "$output" > "$OUTPUT_FILE"
    echo "Content has been saved to $OUTPUT_FILE"
fi

# Print summary
echo "Summary:"
echo "Processed files: $PROCESSED_COUNT"
echo "Processed extensions: $(echo "${PROCESSED_EXTENSIONS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo "Unprocessed files: $UNPROCESSED_COUNT"
echo "Unprocessed extensions: $(echo "${UNPROCESSED_EXTENSIONS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo "List of unprocessed files saved to unprocessed.log"