# CHANGELOG
All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). See the [CONTRIBUTING guide](./CONTRIBUTING.md#Changelog) for instructions on how to add changelog entries.

## [Unreleased 3.x](https://github.com/opensearch-project/neural-search/compare/main...HEAD)

### Features

### Enhancements

### Bug Fixes
* [Hybrid Query] Fix concurrent segment search changing hybrid query results: each shard now keeps at most `pagination_depth` (or `size`) hits per sub-query. Score-ordered, field-sorted and default-mode `collapse` results no longer depend on the segment layout, `rescore` runs once per shard, single-shard requests fetch only the kept hits, and pages beyond `pagination_depth` return "Reached end of result"; distinct-groups collapse not affected ([#2093](https://github.com/opensearch-project/neural-search/pull/2093))
* [Hybrid Query] Fix concurrent sorted hybrid queries returning wrong documents or failing with runtime exception ([#2089](https://github.com/opensearch-project/neural-search/pull/2089))
* [SemanticHighlighter] Find `inner_hits` semantic highlight targets below a `boosting` or `script_score` query that wraps a compound query (for example `boosting > bool > nested`), which batch semantic highlighting silently skipped since 3.9.0 ([#2083](https://github.com/opensearch-project/neural-search/issues/2083))
* [Hybrid Query] Run a fused hybrid query's sub-query inference once per request, special optimization logic for `neural_sparse` sub-query, or a `nested` sub-query over a k-NN or sparse ([#2074](https://github.com/opensearch-project/neural-search/pull/2074))
* [Hybrid Query] Reject an unknown `combination.parameters` and an unknown keys on an inline `fusion` clause ([#2069](https://github.com/opensearch-project/neural-search/pull/2069))
* [Hybrid Query] Reject non-numeric score-combination `weights` with a `400` validation error instead of failing with a `ClassCastException` that surfaced as an internal `500` error ([#2067](https://github.com/opensearch-project/neural-search/pull/2067))
* [Neural Sparse Query] Expose embedded filters to query builder and Lucene query visitor traversal, and reject unsupported filters on `rank_features` fields instead of silently ignoring them ([#2044](https://github.com/opensearch-project/neural-search/pull/2044))
* [Hybrid Query] Fix hybrid `collapse` sorted by ascending `_score` returning wrong documents and an undercounted `hits.total` on shards with more than 4,096 matching documents ([#1795](https://github.com/opensearch-project/neural-search/issues/1795))
* [Ingest Processors] Pass `_routing` to the `skip_existing` lookup so writes to indices with required or custom routing no longer fail or silently re-embed ([#2024](https://github.com/opensearch-project/neural-search/issues/2024))
* [Semantic Field] Fix the semantic field processor invoking the ingest handler twice on embedding-generation failure, which indexed the document without its embedding instead of failing the write ([#2033](https://github.com/opensearch-project/neural-search/pull/2033))
* [Semantic Field] Pass `_routing` to the `skip_existing_embedding` lookup so unchanged documents in routed indices reuse their embeddings instead of being silently re-embedded ([#2040](https://github.com/opensearch-project/neural-search/pull/2040))
* [Hybrid Query] Reject sorting a hybrid query by `_score` more than once, or by ascending `_score` without `collapse`, which returned wrong documents and scores ([#2046](https://github.com/opensearch-project/neural-search/pull/2046))
* [Hybrid Query] Fix hybrid query failing with a `ClassCastException` when a point in time `slice` or an alias filter excludes a shard ([#2045](https://github.com/opensearch-project/neural-search/pull/2045))
* [Ingest Processors] Fix `field_map` entries sharing the same first dotted path segment (e.g. `author.name` and `author.bio`) overwriting each other, which silently dropped embeddings for all but the last field ([#2052](https://github.com/opensearch-project/neural-search/pull/2052))
* [Hybrid Query] Reject a hybrid query without `fusion` nested in a hybrid query with `fusion`, and the other way around ([#2051](https://github.com/opensearch-project/neural-search/pull/2051))
* [Ingest Processors] Deep-merge `field_map` target maps so sibling keys that diverge below the first path segment (e.g. `author.name.first` and `author.name.last`) are no longer dropped ([#2054](https://github.com/opensearch-project/neural-search/pull/2054))
* [Agentic Search] Keep the `agent_steps_summary` returned in a conversational agent's final output, which was dropped for OpenAI native function calling ([#2071](https://github.com/opensearch-project/neural-search/pull/2071))
* [Semantic Field] Stop logging the full ingest document on chunking or model-info failure; log only the document `_id` and `_index` so customer content is no longer written to service logs ([#2057](https://github.com/opensearch-project/neural-search/pull/2057))
* [Sparse ANN] Fix documents with token ids at or above 32768 never matching: approximate search on the Lucene engine returned the documents of the id modulo 32768 instead (e.g. 0 for 32768), and the native engine never matched ids from 32768 to 65535 and failed the shard on an id above 65535. The native engine now folds ids modulo 65536, so ids up to 65535 match exactly ([#2059](https://github.com/opensearch-project/neural-search/pull/2059))
* [Hybrid Query] Fix inaccurate hits.total.value on hybrid queries with a small size, caused by top-k heap eviction feeding min-competitive-score pruning before track_total_hits' threshold was reached ([opensearch-project/OpenSearch#22823](https://github.com/opensearch-project/OpenSearch/issues/22823))

### Infrastructure
* Fetch test models from commit-pinned `raw.githubusercontent.com` URLs, fix ITs for secure cluster ([#2070](https://github.com/opensearch-project/neural-search/pull/2070))
* Fix explain ITs failing on Lucene 10.6, which rewords the k-NN match explanation to `Within top N doc(s)`; assert the shape of that leaf, not Lucene's exact text ([#2077](https://github.com/opensearch-project/neural-search/pull/2077))
* Fix flaky hybrid collapse collector tests by keeping insertion order when the test index is force-merged ([#2075](https://github.com/opensearch-project/neural-search/issues/2075))
* Add a multi-segment index writer helper to the hybrid collapse collector tests ([#2095](https://github.com/opensearch-project/neural-search/pull/2095))

### Documentation

### Maintenance

### Refactoring

