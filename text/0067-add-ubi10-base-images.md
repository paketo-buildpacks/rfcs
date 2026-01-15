# Create UBI10 base images

## Summary

This RFC proposes creating a new repository that will develop, release, and maintain the UBI10 base images for use with buildpacks.

## Motivation

Paketo Buildpacks organization ships UBI images based on RHEL 8 and RHEL 9 operating system and currently the default OS for base images offered by Red Hat is RHEL 10. By shipping UBI10 base images from Paketo Buildpacks organization, we allow users to build their applications with buildpacks on top of UBI10 base images and in addition, users can test their applications against the UBI10 base images for easier transition until UBI8 or UBI9 becomes EOL.

## Detailed Explanation

Create a new repository named `paketo-buildpacks/ubi-10-base-images` and similar to how the (UBI9)[https://github.com/paketo-buildpacks/ubi-9-base-images] repository is structured and works, adjust it accordingly to produce the UBI10 base images.

## Rationale and Alternatives

- We could release the UBI10 images under the UBI9 repository, but this would confuse the users and also does not follow the naming convention we use across the Paketo Buildpacks organization. There is also a risk of hitting github limitations e.g. the number of jobs each github workflow is allowed to run concurrently.

## Implementation

1. Create a new repository named `paketo-buildpacks/ubi-10-base-images`

1. The workflows of this repository should produce at least below container base images based on UBI10 images and also being able to extend the list in case future ubi-\*-extensions be available e.g. python, go, etc.:

- `paketobuildpacks/ubi-10-buid:0.0.1`
- `paketobuildpacks/ubi-10-run:0.0.1`
- `paketobuildpacks/ubi-10-run-nodejs-22:0.0.1`
- `paketobuildpacks/ubi-10-run-nodejs-24:0.0.1`

## Prior Art

The structure and implementation of the repository that will release, maintain, and develop UBI10 base images, will follow the structure/implementation of following stacks/images repositories:

- https://github.com/paketo-buildpacks/ubi-9-base-images
- https://github.com/paketo-buildpacks/ubi8-base-stack
- https://github.com/paketo-buildpacks/jammy-base-stack
- https://github.com/paketo-buildpacks/jammy-full-stack
- https://github.com/paketo-buildpacks/jammy-static-stack
- https://github.com/paketo-buildpacks/ubuntu-noble-base-images

## Unresolved Questions and Bikeshedding

N/A
