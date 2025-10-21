#!/bin/bash

# Script to check current permissions on jinja directories

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Current permissions for jinja directories:"
echo ""

for DIR in jinja-build jinja-templates; do
    FULL_PATH="$SCRIPT_DIR/$DIR"
    if [ -d "$FULL_PATH" ]; then
        echo "Directory: $DIR"
        ls -ld "$FULL_PATH"

        # Check if we can write to it
        if [ -w "$FULL_PATH" ]; then
            echo "  ✓ You have write access"
        else
            echo "  ✗ You do NOT have write access"
        fi

        # Check ACLs if available
        if command -v getfacl > /dev/null 2>&1; then
            echo "  ACLs:"
            getfacl -t "$FULL_PATH" 2>/dev/null | grep -E "^(user|group|other)" | sed 's/^/    /'
        fi
        echo ""
    else
        echo "Directory not found: $DIR"
        echo ""
    fi
done
