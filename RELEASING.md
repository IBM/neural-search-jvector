- [Overview](#overview)
- [Branching](#branching)
    - [Release Branching](#release-branching)
    - [Feature Branches](#feature-branches)
- [Release Labels](#release-labels)
- [Releasing](#releasing)

## Overview

This document explains the release strategy for artifacts in this organization.

## Branching

### Release Branching

Given the current major release of 1.0, projects in this organization maintain the following active branches.

* **main**: The next _major_ release. This is the branch where all merges take place and code moves fast.
* **1.x**: The next _minor_ release. Once a change is merged into `main`, decide whether to backport it to `1.x`.
* **1.0**: The _current_ release. In between minor releases, only hotfixes (e.g. security) are backported to `1.0`.

Label PRs with the next major version label (e.g. `2.0.0`) and merge changes into `main`. Label PRs that you believe need to be backported as `1.x` and `1.0`. Backport PRs by checking out the versioned branch, cherry-pick changes and open a PR against each target backport branch.

### Feature Branches

Do not create branches in the upstream repo, use your fork, for the exception of long lasting feature branches that require active collaboration from multiple developers. Name feature branches `feature/<thing>`. Once the work is merged to `main`, please make sure to delete the feature branch.

## Release Labels

Repositories create consistent release labels, such as `v1.0.0`, `v1.1.0` and `v2.0.0`, as well as `patch` and `backport`. Use release labels to target an issue or a PR for a given release. See [MAINTAINERS](MAINTAINERS.md#triage-open-issues) for more information on triaging issues.

## Keeping Up With Upstream

This repository maintains synchronization with the upstream OpenSearch [neural-search](github.com/Opensearch-project/neural-search) repository. The process is automated as Github workflows and runs weekly (or can be triggered manually).

### Automated Workflow to Sync with `main` branch

The workflow runs every Monday at 9am and creates pull requests to merge upstream changes from `main` branch to both `main` and `jvector_main` forks.

**Workflow**: `.github/workflows/sync-upstream-with-default.yml`

**Process**:
1. Fetches latest changes from `upstream/main` branch
2. Creates pull requests to sync `upstream/main` into both `main` and `jvector_main` branches
3. Pull requests are labeled with `autocut` for easy identification

**Manual Trigger**:
Navigate to Actions > Sync Upstream With Default > Run workflow

**Review Requirements**:
- Review all changes for conflicts
- Verify jvector-specific changes are preserved
- Update documentation if needed

## Releasing

The release process is standard across repositories in this org and is run by a release manager volunteering from amongst [MAINTAINERS](MAINTAINERS.md).

1. **Sync With Upstream**: Ensure the sync workflow has been run and all pull requests are merged into `jvector_main`
2. **Check Nightly Benchmark Results**: Review the [nightly benchmark results](https://opensearch.org/benchmarks/) to identify any performance degradation. Address any significant regressions before proceeding

### Release Workflow

**Workflow**: `.github/workflows/prepare-jvector-release.yml`

**Process**:
1. Navigate to Actions > Cut JVector Release Branch > Run workflow
2. Enter the release version (e.g., 3.7)
3. The workflow will:
   - Sync the upstream release branch to the fork
   - Create a new release branch from `jvector_main`
   - Create a pull request to merge upstream release changes into the newly created release branch
   - Create a tracking issue with next steps

**Post-Workflow Steps**:
1. Review and merge the generated pull request
2. Create and push the release tag
3. Monitor the auto-release workflow for artifact creation

**Checking the release branch locally**:
```bash
# After merging the release PR
git fetch origin
git checkout jvector_3.7

# Create release tag
git tag v3.7
git push origin v3.7
```
