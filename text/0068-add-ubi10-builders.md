# Create UBI10 builders

## Summary

This RFC proposes creating a new repository that will be used to develop, release, and maintain the UBI10 builders. These builders will allow the end users to use the UBI10 base images with ease.

## Motivation

For allowing the users to consume the UBI10 base images in combination with the suggested buildpacks, it is necessary to wrap this logic in to a builder, otherwise it is hard for the users to infer which buildpacks to use for the corresponding base image. In addition, in our integration tests, we use the builders to test the buildpacks, as a result, not following this pattern, would require changing the integration tests on all buildpacks to use the base images instead of the builders.

## Detailed Explanation

Create one new repositoriy named `paketo-buildpacks/ubi-10-builder` which would ship the following builders/images:

- `paketobuildpacks/ubi-10-builder-buildpackless`
- `paketobuildpacks/ubi-10-builder`

## Rationale and Alternatives

An alternative would be to ship the UBI10 builders from the existing UBI9 or UBI8 builder repository, but this would be really confusing for the users as it does not follow the pattern that Paketo Buildpacks follow.

## Implementation

Create the following repositoriy under the paketo-buildpacks organization:

- `paketo-buildpacks/ubi-10-builder`

After the repository has been created, subsequent PRs will add the functionality for producing, maintaining, and releasing the builder images. The implementation will be identical to what we currently have for the `UBI 9` and `Ubuntu Noble` builders.

The `paketo-buildpacks/ubi-10-builder` repository, will output the same images as the `paketo-buildpacks/ubi-9-builder` but for the `RHEL 10` Operating System.

## Prior Art

The implementation will be based on [UBI 9 Builder](https://github.com/paketo-buildpacks/ubi-9-builder) repository

## Unresolved Questions and Bikeshedding

N/A
