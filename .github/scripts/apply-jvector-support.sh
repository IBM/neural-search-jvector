#!/bin/bash
# Master script to apply JVector support transformations
# Applies patches first, then runs transformation scripts
# Usage: ./apply-jvector-support.sh [jvector_version]
# Example: ./apply-jvector-support.sh 3.7.0.0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/../patches"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

JVECTOR_VERSION="${1:-3.6.0.0-SNAPSHOT}"

cd "$REPO_ROOT"

echo "=========================================="
echo "Applying JVector Support"
echo "JVector Version: $JVECTOR_VERSION"
echo "=========================================="
echo ""

# Step 1: Apply patches
echo "Step 1: Applying patches"
for patch in "$PATCHES_DIR"/*.patch; do
    if [ -f "$patch" ]; then
        patch_name=$(basename "$patch")
        if git apply --check "$patch" 2>/dev/null; then
            git apply "$patch"
            echo "Applied: $patch_name"
        else
            echo "Skipped: $patch_name (already applied or conflicts)"
        fi
    fi
done
echo ""

# Step 2: Set jvector version
echo "Step 2: Setting jvector version"
chmod +x "$SCRIPT_DIR"/00-set-jvector-version.sh
"$SCRIPT_DIR"/00-set-jvector-version.sh "$JVECTOR_VERSION"
echo ""

# Step 3: Run transformation scripts
echo "Step 3: Running transformation scripts"
chmod +x "$SCRIPT_DIR"/*.sh

for script in "$SCRIPT_DIR"/[0-9][1-9]*.sh; do
    if [ -f "$script" ]; then
        "$script"
    fi
done
echo ""

echo "=========================================="
echo "JVector Support Applied"
echo "=========================================="

