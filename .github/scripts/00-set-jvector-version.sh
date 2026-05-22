#!/bin/bash
# Set jvector version in build.gradle after patches are applied
# Usage: ./00-set-jvector-version.sh <version>
# Example: ./00-set-jvector-version.sh 3.7.0.0

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

JVECTOR_VERSION="${1:-3.6.0.0-SNAPSHOT}"

echo "Setting jvector version to: $JVECTOR_VERSION"

file="build.gradle"
if [ -f "$file" ]; then
    sed -i.bak "s/jvector_version = System.getProperty(\"jvector.version\", \".*\")/jvector_version = System.getProperty(\"jvector.version\", \"$JVECTOR_VERSION\")/" "$file"
    rm -f "${file}.bak"
    echo "Updated: $file"
else
    echo "Error: build.gradle not found"
    exit 1
fi

echo "JVector version set to $JVECTOR_VERSION"
