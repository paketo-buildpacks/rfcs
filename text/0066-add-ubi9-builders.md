# Create UBI9 builders

## Summary

This RFC proposes creating three new repositories that will be used to develop, release, and maintain the UBI9 builders. These builders will allow end users to use the UBI9 stack more easily.

## Motivation

Recently, the RFC for adding UBI9 base images to paketo-buildpacks has been approved. In order to allow the users to consume the base images in combination with the suggested buildpacks it is necessary to wrap this logic in a builder, otherwise it is hard for the users to infer which buildpacks with which images to use. In addition, in our integration tests, we use the builders to test the buildpacks a result, not following this pattern, would require changing the integration tests on all buildpacks to use the base images instead of the builders.

## Detailed Explanation

Create three new repositories named `paketo-buildpacks/builder-ubi9-buildpackless-base`, `paketo-buildpacks/builder-ubi9-base` and `paketo-buildpacks/ubi-9-builder`.

## Rationale and Alternatives

An alternative would be to ship the UBI9 builders from the existing UBI8 builder repositories, but the existing shared scripts don’t support this yet, it would not be consistent with what is done for other stacks, and would also be confusing for the users to use the UBI9 builders from a repo called UBI8.

## Implementation

Create the following repositories under the paketo-buildpacks organization

- `paketo-buildpacks/builder-ubi9-buildpackless-base`
- `paketo-buildpacks/builder-ubi9-base`
- `paketo-buildpacks/ubi-9-builder`

After the repositories have been created, subsequent PRs will add the functionality for producing, maintaining, and releasing the images for each of the aforementioned repositories. For the `builder-ubi9-buildpackless-base` and `builder-ubi9-base` the implementation will be almost identical to the one from `builder-ubi8-buildpackless-base` and `builder-ubi8-base` accordingly, with the only difference, that instead of using UBI8 base images, we will use the UBI9 ones.

For the `paketo-buildpacks/ubi-9-builder`, the implementation will output the same images as the `builder-ubi9-buildpackless-base` with a future plan to produce, maintain and release all the UBI9 builders from the `paketo-buildpacks/ubi-9-builder` repository We’d like to introduce this repository now so that we can track the progress of using a single builder repository that is being worked on for other builders/stacks.

## Prior Art

The implementation will be based on the following repositories:

- [builder-ubi8-buildpackless-base](https://github.com/paketo-buildpacks/builder-ubi8-buildpackless-base) for the `paketo-buildpacks/builder-ubi9-buildpackless-base`
- [builder-ubi8-base](https://github.com/paketo-buildpacks/builder-ubi8-base) for the `paketo-buildpacks/builder-ubi9-base`
- [ubuntu-noble-builder](https://github.com/paketo-buildpacks/ubuntu-noble-builder) for the `paketo-buildpacks/ubi-9-builder`

## Unresolved Questions and Bikeshedding

For the `ubi-9-builder` it is necessary for the workflow to support producing multiple images and multiple architectures. The work in the common scripts to support that is not yet done so we will follow the same rationale as currently with `ubuntu-noble-builder`, which is to produce only one image, the buildpackless one, in amd64 architecture.
