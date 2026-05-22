#!/bin/bash
# Replace KNN plugin imports with NeuralSearchConstants imports
# Only replaces imports that actually exist in the files

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Replacing KNN imports with NeuralSearchConstants"

# Files that import MODEL_INDEX_NAME
for file in \
    "src/testFixtures/java/org/opensearch/neuralsearch/BaseNeuralSearchIT.java" \
    "src/testFixtures/java/org/opensearch/neuralsearch/OpenSearchSecureRestTestCase.java"
do
    if [ -f "$file" ] && grep -q "import static org.opensearch.knn.common.KNNConstants.MODEL_INDEX_NAME" "$file"; then
        sed -i.bak 's|import static org.opensearch.knn.common.KNNConstants.MODEL_INDEX_NAME;|import static org.opensearch.neuralsearch.constants.NeuralSearchConstants.MODEL_INDEX_NAME;|' "$file"
        rm -f "${file}.bak"
        echo "Updated: $file"
    fi
done

# File that imports MODEL_ID
file="src/test/java/org/opensearch/neuralsearch/processor/mmr/MMRNeuralQueryTransformerIT.java"
if [ -f "$file" ] && grep -q "import static org.opensearch.knn.common.KNNConstants.MODEL_ID" "$file"; then
    sed -i.bak 's|import static org.opensearch.knn.common.KNNConstants.MODEL_ID;|import static org.opensearch.neuralsearch.constants.NeuralSearchConstants.MODEL_ID;|' "$file"
    rm -f "${file}.bak"
    echo "Updated: $file"
fi

echo "Import replacement complete"
