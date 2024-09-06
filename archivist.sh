#!/bin/bash

# Function to display help menu
show_help() {
    echo "Usage: $0 [directory] [options]"
    echo
    echo "Description:"
    echo "  This script processes tracked files in a Git repository, concatenating their contents"
    echo "  into a single file or copying them to the clipboard. It respects .gitignore and offers"
    echo "  options to customize behavior."
    echo
    echo "Options:"
    echo "  -h, --help                       Show this help message"
    echo "  --clipboard                      Copy the result to clipboard instead of creating a file"
    echo "  --output <file>                  Specify a custom output file (default: files.txt)"
    echo "  --supported-binary-files <types> Specify additional supported binary file types (e.g., 'CSV|JSON')"
    echo
    echo "Examples:"
    echo "  $0 /path/to/project"
    echo "  $0 . --clipboard --supported-binary-files 'CSV|JSON'"
    echo "  $0 /path/to/project --output result.txt"
}

# Initial configuration
DIRECTORY="."
OUTPUT_FILE="files.txt"
USE_CLIPBOARD=false
SUPPORTED_BINARY_TYPES=""

# Process arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        --clipboard) USE_CLIPBOARD=true; shift ;;
        --output) shift; OUTPUT_FILE="$1"; shift ;;
        --supported-binary-files) shift; SUPPORTED_BINARY_TYPES="$1"; shift ;;
        -*) echo "Unknown option: $1" >&2; show_help; exit 1 ;;
        *) DIRECTORY="$1"; shift ;;
    esac
done

# Change to the specified directory
cd "$DIRECTORY" || { echo "Error: Unable to change to directory $DIRECTORY"; exit 1; }

# Check if it's a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not a Git repository"
    exit 1
fi

# Get the current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Function to process a file
process_file() {
    local file="$1"
    local mime_type=$(file -b --mime-type "$file")

    echo "$file"
    echo '```'

    if [[ $mime_type == text/* || $mime_type == application/json || $mime_type == application/xml ]]; then
        cat "$file"
    elif [[ $mime_type == application/* && $SUPPORTED_BINARY_TYPES == *"${file##*.}"* ]]; then
        cat "$file"
    else
        echo "(Binary file, content not shown)"
    fi

    echo '```'
    echo
}

# Process files
output=$(git ls-tree -r "$BRANCH" --name-only | while read -r file; do
    if [ -f "$file" ]; then
        process_file "$file"
    fi
done)

# Handle output
if [ "$USE_CLIPBOARD" = true ]; then
    echo "$output" | xclip -selection clipboard
    echo "Content has been copied to clipboard."
else
    echo "$output" > "$OUTPUT_FILE"
    echo "Content has been saved to $OUTPUT_FILE"
fi