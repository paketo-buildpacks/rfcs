# Create a draft branch for composite/meta buildpacks

## Summary

Currently component buildpack bumps are created as PRs against the main branch, e.g. see [here](https://github.com/paketo-buildpacks/java/pull/873).
This RFC proposes changing the CI to create these dependency bumps as commits to a PR against a new branch, e.g. `draft`.    

## Motivation

This will allow us to achieve the following improvements:

1. Auto-merging of component buildpack PRs into this draft branch 
2. Manual review can be performed with a single PR before merging to main
2. Integration tests can be run on merging to main ensuring all changes in the release are covered

## Detailed Explanation

Currently the component dependency PRs must be manually approved and merged separately, even though their changes do not cause merge conflicts. Auto-merging these will reduce the maintainence burden involved here.
Integration tests can configured to run on merges to the main branch, which could happen once per week before a release, or more frequently if necessary for a specific purpose.

## Rationale and Alternatives

1. Do not change the current CI/branch configuration - integration tests could be run via a manual step before release.
2. Do not change the current CI/branch configuration - create new release tags as a separate initial step before a release is published. Integration tests could be run on tag creation instead, with the publish action potentially triggered from passed tests. 

## Implementation

For the composite/meta buildpack repositories:

1. The pipeline-builder CI workflow step that updates package [dependencies](https://github.com/paketo-buildpacks/pipeline-builder/blob/main/octo/package_dependencies.go) would be changed to checkout a draft branch rather than the default of main. The PR for containing the update would then be created targeting this branch. 
2. We would likely need a new workflow which triggers on merges to the 'draft' branch and opens/updates a PR to merge the dependency changes into main. The integration tests could be triggered here also.

## Prior Art

This is how `buildpack.toml` is updated in non-Java composite buildpacks, see [this PR](https://github.com/paketo-buildpacks/python/pull/555/files)

## Unresolved Questions and Bikeshedding

N/A
