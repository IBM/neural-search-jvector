#!/bin/bash
# Update build.gradle with JVector-specific configurations
# This script modifies build.gradle to support conditional JVector/KNN plugin usage
# Usage: Called by apply-jvector-support.sh with JVECTOR_VERSION environment variable

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

file="build.gradle"

echo "Updating $file with JVector configurations (version: $JVECTOR_VERSION)..."

# 1. Add jvector_version and isJVectorEngine variables after opensearch_version
if ! grep -q "jvector_version = System.getProperty" "$file"; then
    awk -v version="$JVECTOR_VERSION" '/opensearch_version = System.getProperty/ {print; print "        jvector_version = System.getProperty(\"jvector.version\", \"" version "\")"; next} 1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added jvector_version variable with default: $JVECTOR_VERSION"
fi

if ! grep -q "isJVectorEngine = " "$file"; then
    awk '/isSnapshot = "true" == System.getProperty/ {print; print "        isJVectorEngine = \"true\" == System.getProperty(\"opensearch.knn.isJVectorEngine\", \"false\")"; next} 1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added isJVectorEngine variable"
fi

# 2. Update extendedPlugins to conditionally include opensearch-jvector
if ! grep -q "if (isJVectorEngine)" "$file" | head -1; then
    awk "/extendedPlugins = \['opensearch-knn', 'transport-grpc'\]/ {print; print \"    if (isJVectorEngine) {\"; print \"        extendedPlugins.remove('opensearch-knn')\"; print \"        extendedPlugins.add('opensearch-jvector')\"; print \"    }\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added conditional extendedPlugins logic"
fi

# 3. Add jvectorJarDirectory variable after knnJarDirectory
if ! grep -q "jvectorJarDirectory = " "$file"; then
    awk '/def knnJarDirectory = / {print; print "def jvectorJarDirectory = \"$buildDir/dependencies/opensearch-jvector-plugin\""; next} 1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added jvectorJarDirectory variable"
fi

# 4. Replace zipArchive dependency for opensearch-knn with conditional logic
if grep -q "zipArchive group: 'org.opensearch.plugin', name:'opensearch-knn'" "$file" && ! grep -q "// Conditionally include either jvector or knn plugin" "$file"; then
    awk "/zipArchive group: 'org.opensearch.plugin', name:'opensearch-knn'/ {print \"\"; print \"    // Conditionally include either jvector or knn plugin\"; print \"    if (isJVectorEngine) {\"; print \"        zipArchive group: 'org.opensearch.plugin', name: 'opensearch-jvector-plugin', version: \\\"\${jvector_version}\\\"\"; print \"    } else {\"; print \"        zipArchive group: 'org.opensearch.plugin', name: 'opensearch-knn', version: \\\"\${opensearch_build}\\\"\"; print \"    }\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated zipArchive dependency with conditional logic"
fi

# 5. Replace compileOnly dependency with conditional logic
if grep -q 'compileOnly fileTree(dir: knnJarDirectory' "$file" && ! grep -q "// Conditionally compile with either jvector or knn plugin" "$file"; then
    awk "/compileOnly fileTree\(dir: knnJarDirectory/ {print \"\"; print \"    // Conditionally compile with either jvector or knn plugin\"; print \"    // Cannot include both as they have duplicate classes (jar hell)\"; print \"    if (isJVectorEngine) {\"; print \"        compileOnly files(\\\"\${jvectorJarDirectory}/opensearch-jvector-\${jvector_version}.jar\\\")\"; print \"    } else {\"; print \"        compileOnly files(\\\"\${knnJarDirectory}/opensearch-knn-\${opensearch_build}.jar\\\")\"; print \"        compileOnly files(\\\"\${knnJarDirectory}/remote-index-build-client-\${opensearch_build}.jar\\\")\"; print \"    }\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated compileOnly dependencies with conditional logic"
fi

# 6. Update test dependencies with conditional logic
if grep -q 'testFixturesImplementation fileTree(dir: knnJarDirectory' "$file" && ! grep -q "// Test dependencies - use EITHER knn OR jvector" "$file"; then
    awk "
    /testFixturesImplementation fileTree\(dir: knnJarDirectory/ {
        in_block=1
        print \"    // Test dependencies - use EITHER knn OR jvector, not both\"
        print \"    // Having both causes jar hell due to duplicate classes\"
        print \"    if (isJVectorEngine) {\"
        print \"        testFixturesImplementation files(\\\"\${jvectorJarDirectory}/opensearch-jvector-\${jvector_version}.jar\\\")\"
        print \"        testImplementation files(\\\"\${jvectorJarDirectory}/opensearch-jvector-\${jvector_version}.jar\\\")\"
        print \"        // jvector doesn't bundle commons-lang 2.x, add it explicitly\"
        print \"        testImplementation group: 'commons-lang', name: 'commons-lang', version: '2.6'\"
        print \"        testFixturesImplementation group: 'commons-lang', name: 'commons-lang', version: '2.6'\"
        print \"    } else {\"
        print \"        testFixturesImplementation fileTree(dir: knnJarDirectory, include: [\\\"opensearch-knn-\${opensearch_build}.jar\\\", \\\"remote-index-build-client-\${opensearch_build}.jar\\\"])\"
        print \"        testImplementation fileTree(dir: knnJarDirectory, include: [\\\"opensearch-knn-\${opensearch_build}.jar\\\", \\\"remote-index-build-client-\${opensearch_build}.jar\\\"])\"
        print \"    }\"
        next
    }
    /testImplementation fileTree\(dir: knnJarDirectory/ && in_block {
        in_block=0
        next
    }
    1
    " "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated test dependencies with conditional logic"
fi

# 7. Add extractJvectorJar task after extractKnnJar
if ! grep -q "task extractJvectorJar" "$file"; then
    awk "
    /^task extractKnnJar/ {in_task=1}
    in_task && /^}/ {
        print
        print \"\"
        print \"// Extract jvector jar for compilation\"
        print \"task extractJvectorJar(type: Copy) {\"
        print \"    mustRunAfter()\"
        print \"    from(zipTree(configurations.zipArchive.find { it.name.startsWith(\\\"opensearch-jvector\\\")}))\"
        print \"    into jvectorJarDirectory\"
        print \"}\"
        in_task=0
        next
    }
    1
    " "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added extractJvectorJar task"
fi

# 8. Update delombok task dependencies
if ! grep -q "// Set up dependencies for delombok task based on engine type" "$file"; then
    awk "/project.tasks.delombok.dependsOn\(extractKnnJar\)/ {print \"// Set up dependencies for delombok task based on engine type\"; print \"if (isJVectorEngine) {\"; print \"    project.tasks.delombok.dependsOn(extractJvectorJar)\"; print \"} else {\"; print \"    project.tasks.delombok.dependsOn(extractKnnJar)\"; print \"}\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated delombok task dependencies"
fi

# 9. Update compileJava dependencies
if grep -q "compileJava {" "$file" && ! grep -A5 "compileJava {" "$file" | grep -q "if (isJVectorEngine)"; then
    awk "
    /^compileJava \{/ {print; in_compile=1; next}
    in_compile && /dependsOn extractKnnJar/ {
        print \"    if (isJVectorEngine) {\"
        print \"        dependsOn extractJvectorJar\"
        print \"    } else {\"
        print \"        dependsOn extractKnnJar\"
        print \"    }\"
        in_compile=0
        next
    }
    1
    " "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated compileJava dependencies"
fi

# 10. Update compileTestJava dependencies
if grep -q "^compileTestJava {" "$file" && ! grep -A3 "^compileTestJava {" "$file" | grep -q "if (isJVectorEngine)"; then
    awk "/^compileTestJava \{/ {print; print \"    if (isJVectorEngine) {\"; print \"        dependsOn extractJvectorJar\"; print \"    } else {\"; print \"        dependsOn extractKnnJar\"; print \"    }\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated compileTestJava dependencies"
fi

# 11. Update compileTestFixturesJava dependencies
if grep -q "^compileTestFixturesJava {" "$file" && ! grep -A3 "^compileTestFixturesJava {" "$file" | grep -q "if (isJVectorEngine)"; then
    awk "/^compileTestFixturesJava \{/ {print; print \"    if (isJVectorEngine) {\"; print \"        dependsOn extractJvectorJar\"; print \"    } else {\"; print \"        dependsOn extractKnnJar\"; print \"    }\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Updated compileTestFixturesJava dependencies"
fi

# 12. Add isJVectorEngine system property to integTest
if grep -q "integTest {" "$file" && ! grep -A20 "integTest {" "$file" | grep -q "systemProperty 'opensearch.knn.isJVectorEngine'"; then
    awk "/systemProperty\(\"password\", password\)/ {print; print \"    systemProperty 'opensearch.knn.isJVectorEngine', isJVectorEngine\"; next} 1" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "  - Added isJVectorEngine system property to integTest"
fi

# 13. Update comments for plugin installation
sed 's|// Install K-NN/ml-commons plugins on the integTest cluster nodes except security|// Install plugins on the integTest cluster|g' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
sed 's|// This installs our neural-search plugin into the testClusters|// Install neural-search plugin|g' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "build.gradle updated successfully"
