#!/bin/bash
# Update ValidateDependentPluginInstallationIT to use conditional plugin dependencies

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Updating plugin installation test"

file="src/test/java/org/opensearch/neuralsearch/plugin/ValidateDependentPluginInstallationIT.java"
if [ -f "$file" ]; then
    perl -i -pe '
        if (/private static final Set<String> DEPENDENT_PLUGINS = Set\.of\("opensearch-knn"\);/) {
            $_ = "    private static final Set<String> DEPENDENT_PLUGINS = Boolean.getBoolean(\"opensearch.knn.isJVectorEngine\")\n" .
                 "        ? Set.of(\"opensearch-jvector\")\n" .
                 "        : Set.of(\"opensearch-knn\");\n";
        }
    ' "$file"
    echo "Updated: $file"
fi

echo "Plugin installation test updated"
