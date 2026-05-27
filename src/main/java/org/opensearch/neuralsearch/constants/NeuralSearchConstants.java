/*
 * Copyright OpenSearch Contributors
 * SPDX-License-Identifier: Apache-2.0
 */
package org.opensearch.neuralsearch.constants;

/**
 * Constants used by neural-search plugin.
 * These constants match opensearch-knn's KNNConstants to maintain compatibility
 * while eliminating direct dependency on the knn plugin's constant definitions.
 *
 * This allows neural-search to work with both opensearch-knn and opensearch-jvector plugins
 * without requiring KNNConstants to be present at compile time.
 */
public final class NeuralSearchConstants {

    private NeuralSearchConstants() {}

    // Model index constant used in test cleanup to skip model index deletion
    public static final String MODEL_INDEX_NAME = ".plugins-ml-model";

    // Model ID constant used in MMR tests
    public static final String MODEL_ID = "model_id";
}
