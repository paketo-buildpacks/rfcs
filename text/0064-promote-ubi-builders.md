# Promote ubi builders to paketo-buildpacks

## Summary

Addition of ubi stacks was discussed and approved in
[https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md])https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md).

Initially repositories were added to to paketo-community to reflect that they were under early development. 

The ubi builders have been being built and published since August 2023, and they use the common Paketo workflows.

No major updates are planned to the builders at this time.

There are active maintainers for the builders and no significant issues open in the repo.

The builders are ready to be promoted to paketo-buildpacks.

## Motivation

Addition of ubi stacks was approved in
[https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md])https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md).

Promotion of builders to paketo-buildpacks from paketo-community is the next step towards completing that.

## Detailed Explanation

* Rename https://github.com/paketo-community/builder-ubi-base/ to https://github.com/paketo-buildpacks/builder-ubi8-base/
* Rename https://github.com/paketo-community/builder-ubi-buildpackless-base/ to https://github.com/paketo-buildpacks/builder-ubi8-buildpackless-base/
* Rename all references to paketo-community/builder-ubi-base to paketo-buildpacks/builder-ubi8-base across the Paketo projects (references in integration testing) 
* Rename all references to paketo-community/builder-ubi-buildpackless-base to paketo-buildpacks/builder-ubi8-buildpackless-base across the Paketo projects (references in integration testing) 

The rename from ubi to ubi8 is to better reflect that the builder is for ubi8. Just like ubuntu there are different streams of ubi (8, 9, ...) and this is
a good time to make the change.

## Rationale and Alternatives

The builders are ready to be promoted to paketo-buildpacks there is no obvious reasons not to move to packeto-buildpacks.

Alternative - leave the builder where is in paketo-community and define some additional milestones to be achived before it can be moved.

## Implementation

See detailed explaination above in terms of the steps to implement.

This will multple PRs to the repos that use the ubi builders for integration testing, but the main risk is missing updates during the transition. This is manageable and should not
have a major impact. 

## Prior Art


## Unresolved Questions and Bikeshedding

