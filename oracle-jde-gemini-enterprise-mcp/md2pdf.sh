#!/bin/bash

# Verify required commands are available
MISSING=()
for cmd in pandoc weasyprint; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Error: the following required commands are not installed:"
    for cmd in "${MISSING[@]}"; do
        echo "  - $cmd"
    done
    echo ""
    echo "Install them with:"
    echo "  brew install pandoc && pip install weasyprint    # macOS"
    echo "  apt-get install pandoc && pip install weasyprint # Debian/Ubuntu"
    exit 1
fi

# Check if a file or directory was provided
if [ -z "$1" ]; then
    echo "Usage: ./md2pdf.sh <file_or_directory>"
    exit 1
fi

TARGET=$1

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local output_file="${input_file%.md}.pdf"
    
    echo "Converting: $input_file -> $output_file"
    
    # Using pandoc with WeasyPrint as the PDF engine.
    # Alternatives: --pdf-engine=xelatex (requires MacTeX) or --pdf-engine=typst (requires pandoc >= 3)
    pandoc "$input_file" -o "$output_file" --pdf-engine=weasyprint \
        --metadata title="Document" \
        -V margin-top=20 -V margin-bottom=20 \
        -V margin-left=20 -V margin-right=20

    if [ $? -eq 0 ]; then
        echo "Successfully converted $input_file"
    else
        echo "Error: Failed to convert $input_file"
    fi
}

# Logic to handle directory vs single file
if [ -d "$TARGET" ]; then
    echo "Processing all Markdown files in directory: $TARGET"
    for file in "$TARGET"/*.md; do
        [ -e "$file" ] || continue
        convert_file "$file"
    done
elif [ -f "$TARGET" ]; then
    convert_file "$TARGET"
else
    echo "Error: $TARGET is not a valid file or directory."
    exit 1
fi
