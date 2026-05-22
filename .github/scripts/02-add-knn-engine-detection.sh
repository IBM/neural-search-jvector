#!/bin/bash
# Add KNNEngine detection logic to test files
# Detects whether JVector or KNN plugin is loaded based on jar filename

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Adding KNNEngine detection logic"

# Add to NeuralKNNQueryBuilderTests.java
file="src/test/java/org/opensearch/neuralsearch/query/NeuralKNNQueryBuilderTests.java"
if [ -f "$file" ]; then
    perl -i -pe '
        if (/mockContext = mock\(QueryShardContext\.class\);/ && !$added) {
            $_ .= "\n" .
                  "        // detect whether JVector or Knn plugin is loaded, and set KNNEngine accordingly\n" .
                  "        String jarPath = VectorDataType.class.getProtectionDomain().getCodeSource().getLocation().toURI().getPath();\n" .
                  "        KNNEngine knnEngine;\n" .
                  "        String jarFileName = jarPath.substring(jarPath.lastIndexOf(\"/\") + 1);\n" .
                  "        if (jarFileName.contains(\"jvector\")) knnEngine = KNNEngine.valueOf(\"JVECTOR\");\n" .
                  "        else knnEngine = KNNEngine.valueOf(\"FAISS\");\n" .
                  "\n";
            $added = 1;
        }
        s/KNNMethodContext knnMethodContext = new KNNMethodContext\(KNNEngine\.FAISS,/KNNMethodContext knnMethodContext = new KNNMethodContext(knnEngine,/;
    ' "$file"
    echo "Updated: $file"
fi

# Add to HybridQueryBuilderTests.java - add knnEngine field and initialize in setUp
file="src/test/java/org/opensearch/neuralsearch/query/HybridQueryBuilderTests.java"
if [ -f "$file" ]; then
    # Add knnEngine field declaration after class declaration
    perl -i -pe '
        if (/^public class HybridQueryBuilderTests/ && !$field_added) {
            $_ .= "\n    private KNNEngine knnEngine;\n";
            $field_added = 1;
        }
    ' "$file"
    
    # Add knnEngine initialization after the last TestUtils.initializeEventStatsManager() in setUp
    perl -i -0777 -pe '
        if (!$setup_added) {
            s/(initKNNSettings\(\);\s+TestUtils\.initializeEventStatsManager\(\);)/$1\n        \/\/ detect whether JVector or Knn plugin is loaded, and set KNNEngine accordingly\n        String jarPath = VectorDataType.class.getProtectionDomain().getCodeSource().getLocation().toURI().getPath();\n        String jarFileName = jarPath.substring(jarPath.lastIndexOf("\/") + 1);\n        if (jarFileName.contains("jvector")) knnEngine = KNNEngine.valueOf("JVECTOR");\n        else knnEngine = KNNEngine.valueOf("FAISS");/;
            $setup_added = 1;
        }
        s/KNNMethodContext knnMethodContext = new KNNMethodContext\(KNNEngine\.FAISS,/KNNMethodContext knnMethodContext = new KNNMethodContext(knnEngine,/g;
    ' "$file"
    echo "Updated: $file"
fi

echo "KNNEngine detection logic added"
