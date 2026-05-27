#!/bin/bash
# Update HighlightExtractorUtils to use conditional engine/method names

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Updating HighlightExtractorUtils"

file="src/main/java/org/opensearch/neuralsearch/highlight/utils/HighlightExtractorUtils.java"
if [ -f "$file" ]; then
    perl -i -pe '
        s/private static final String DEFAULT_ENGINE = "lucene";/private static final String DEFAULT_ENGINE = Boolean.getBoolean("opensearch.knn.isJVectorEngine") ? "jvector" : "lucene";/;
        s/private static final String DEFAULT_METHOD = "hnsw";/private static final String DEFAULT_METHOD = Boolean.getBoolean("opensearch.knn.isJVectorEngine") ? "disk_ann" : "hnsw";/;
    ' "$file"
    echo "Updated: $file"
fi

echo "HighlightExtractorUtils updated"
