#!/bin/bash
# Add method_parameters to MMR test queries
# Adds overquery_factor parameter to neural queries in MMR tests

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Adding method_parameters to MMR tests"

file="src/test/java/org/opensearch/neuralsearch/processor/mmr/MMRNeuralQueryTransformerIT.java"
if [ -f "$file" ]; then
    perl -i -pe '
        if (/\.field\(NeuralQueryBuilder\.QUERY_TEXT_FIELD\.getPreferredName\(\), SEMANTIC_DOC_VALUE_1\)/ && !$in_method_params) {
            $_ .= "            .startObject(\"method_parameters\")\n" .
                  "            .field(\"overquery_factor\", 20)\n" .
                  "            .endObject()\n";
        }
        if (/\.field\(MODEL_ID, modelId\)/ && !$in_method_params) {
            $_ .= "            .startObject(\"method_parameters\")\n" .
                  "            .field(\"overquery_factor\", 20)\n" .
                  "            .endObject()\n";
        }
    ' "$file"
    echo "Updated: $file"
fi

echo "MMR method_parameters added"
