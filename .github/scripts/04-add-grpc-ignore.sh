#!/bin/bash
# Add @AwaitsFix annotation to gRPC test methods
# gRPC tests are not supported in JVector

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Adding @AwaitsFix to gRPC tests"

file="src/test/java/org/opensearch/neuralsearch/grpc/HybridQueryGrpcIT.java"
if [ -f "$file" ]; then
    # Replace @Ignore import with LuceneTestCase import
    if grep -q "import org.junit.Ignore;" "$file"; then
        sed -i.bak 's|import org.junit.Ignore;|import org.apache.lucene.tests.util.LuceneTestCase;|' "$file"
        rm -f "${file}.bak"
    fi
    
    # Replace @Ignore annotations with @AwaitsFix
    sed -i.bak 's|@Ignore("JVector plugin does not include gRPC KNN query converter")|@LuceneTestCase.AwaitsFix(bugUrl = "https://github.com/opensearch-project/opensearch-jvector/issues/391")|g' "$file"
    rm -f "${file}.bak"
    
    echo "Updated: $file"
else
    echo "Warning: gRPC test file not found (may not exist in this version)"
fi

echo "gRPC @AwaitsFix annotation added"
