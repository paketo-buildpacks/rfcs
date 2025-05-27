# Create UBI9 base images

## Summary

This RFC proposes creating a new repository that will develop, release, and maintain the UBI9 base images for use with buildpacks.

## Motivation

Paketo Buildpacks organization ships UBI images based on RHEL 8 operating system and currently the default OS for base images offered by Red Hat is RHEL 9. By shipping UBI9 base images from Paketo Buildpacks organization, we allow users to build their applications with buildpacks on top of UBI9 base images and in addition, users can test their applications against the UBI9 base images for easier transition until UBI8 becomes EOL.

## Detailed Explanation

Create a new repository named `paketo-buildpacks/ubi-9-base-images` and similar to how the (UBI8)[https://github.com/paketo-buildpacks/ubi8-base-stack] repository is structured and works, adjust it accordingly to produce the UBI9 base images.

## Rationale and Alternatives

- We could release the UBI9 images under the UBI8 repository, but this would confuse the users and also does not follow the naming convention we use across the Paketo Buildpacks organization.
- We could have ubi8 and ubi9 images under one repository, but in that case, there is a risk of hitting github limitations, e.g., the number of jobs each github workflow is allowed to run concurrently, and it will also trigger the UBI8 releases in case there is a UBI9 one available.

## Implementation

1. Create a new repository named `paketo-buildpacks/ubi-9-base-images`

1. The workflows of this repository should produce at least below container base images based on UBI9 images and also being able to extend the list in case future ubi-\*-extensions be available e.g. python, go, etc.:

- `build-ubi9-base`
- `run-ubi9-base`
- `run-java-8-ubi9-base`
- `run-java-11-ubi9-base`
- `run-java-17-ubi9-base`
- `run-java-21-ubi9-base`
- `run-nodejs-16-ubi9-base`
- `run-nodejs-18-ubi9-base`
- `run-nodejs-20-ubi9-base`

## Prior Art

The structure and implementation of the repository that will release, maintain, and develop UBI9 base images, will follow the structure/implementation of following stacks/images repositories:

- https://github.com/paketo-buildpacks/ubi8-base-stack
- https://github.com/paketo-buildpacks/jammy-base-stack
- https://github.com/paketo-buildpacks/jammy-full-stack
- https://github.com/paketo-buildpacks/jammy-static-stack
- https://github.com/paketo-buildpacks/ubuntu-noble-base-images

## Unresolved Questions and Bikeshedding

N/A
