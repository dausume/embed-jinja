#!/bin/bash

# Script to fix permissions on jinja-build and jinja-templates directories
# Ensures both the user and Docker can access these directories

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${SUDO_USER:-$USER}"
USER_ID=$(id -u "$USER_NAME")

# Check if docker group exists
if ! getent group docker > /dev/null 2>&1; then
    echo "Warning: docker group does not exist. Creating it..."
    sudo groupadd docker
fi

# Add user to docker group if not already a member
if ! groups "$USER_NAME" | grep -q docker; then
    echo "Adding $USER_NAME to docker group..."
    sudo usermod -aG docker "$USER_NAME"
    echo "Note: You may need to log out and back in for group changes to take effect"
fi

# Directories to fix
DIRS=(
    "$SCRIPT_DIR/jinja-build"
    "$SCRIPT_DIR/jinja-templates"
)

echo "Fixing permissions for jinja directories..."

for DIR in "${DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Processing: $DIR"

        # Change ownership to user:docker
        sudo chown -R "$USER_NAME:docker" "$DIR"

        # Set permissions: rwxrwxr-x (775)
        # - User (you) can read, write, execute
        # - Group (docker) can read, write, execute
        # - Others can read and execute
        sudo chmod -R 775 "$DIR"

        # Set ACLs for additional control (optional but recommended)
        # This ensures new files inherit the correct permissions
        if command -v setfacl > /dev/null 2>&1; then
            # Set default ACLs for directories
            sudo setfacl -R -d -m u::rwx,g::rwx,o::r-x "$DIR"
            # Set ACLs for existing files/directories
            sudo setfacl -R -m u::rwx,g::rwx,o::r-x "$DIR"
            echo "  ✓ ACLs set"
        fi

        echo "  ✓ Ownership: $USER_NAME:docker"
        echo "  ✓ Permissions: 775 (rwxrwxr-x)"
    else
        echo "Warning: Directory not found: $DIR"
    fi
done

echo ""
echo "✓ Permissions fixed successfully!"
echo ""
echo "Summary:"
echo "  - Directories owned by: $USER_NAME:docker"
echo "  - User permissions: read, write, execute"
echo "  - Docker group permissions: read, write, execute"
echo "  - Others permissions: read, execute"
echo ""
echo "Both you and Docker containers can now access and modify these directories."

# Verify current permissions
echo ""
echo "Current permissions:"
ls -la "$SCRIPT_DIR" | grep -E "jinja-build|jinja-templates"
