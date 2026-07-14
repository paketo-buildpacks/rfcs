# Builders based on Ubuntu 2026.04: Resolute Raccoon

## Summary

A set of builders based on Ubuntu 2026.04 LTS (Resolute Raccoon) base images will be
maintained by Paketo, per base images [RFC 0010](./../stacks/0010-resolute-raccoon.md).
Builders are an important way for Paketo users to consume base images; they can be
used as an input to the `pack` CLI. Paketo should maintain a set of builders that
use the Resolute Raccoon base images. They should be developed, released, and
maintained by the Builders subteam. These new builders should come in "base"
(`ubuntu-resolute-builder`) and "buildpackless" (`ubuntu-resolute-builder-buildpackless`) variants.

## Motivation

Paketo [plans to support Resolute Raccoon base images](./../stacks/0010-resolute-raccoon.md).
Paketo [builders](https://paketo.io/docs/concepts/builders/) are a common way
for Paketo users to consume Paketo base images, buildpacks, and the Cloud Native
Buildpacks (CNB) lifecycle. In order for many Paketo users to get value from
Resolute Raccoon base images, we'll need to provide Resolute Raccoon builders.

## Detailed Explanation

### Variants

The Resolute builders will be available in 2 variants that align to the existing
Noble-based builders. These will be called:

- `ubuntu-resolute-builder`
- `ubuntu-resolute-builder-buildpackless`

The Resolute builders will eventually\* contain corresponding sets of buildpacks
to their Noble counterparts. Buildpackless builders will contain no buildpacks,
as described in the [Buildpackless Builders RFC](../0030-buildpackless-builders.md).

\*Note: Some buildpacks (or the tools they install) may not yet be compatible
with the Resolute Raccoon operating system. For instance, this is an
[open discussion](https://github.com/dotnet/core/issues/7038) for .NET Core.
While the Resolute builders should mirror existing Paketo builders as best as possible,
if buildpack or language support presents a blocker, it is acceptable to
release builders with best-effort subsets of the buildpacks supported by the Noble builders.

Note: It will be a requirement for composite buildpacks that are added into the Resolute Raccoon builder that they are flattened. Flattening buildpacks reduces the layers down to one, which thereby reduces the layer count of the builder. This allows us to ship more buildpacks without hitting layer limits.

### Image Naming and Tagging

The builders will name and tag their release images with the following pattern:

```
paketobuildpacks/ubuntu-{distro}-builder:{version}
```

and in case of the buildpackless builders will have the following pattern:

```
paketobuildpacks/ubuntu-{distro}-builder-buildpackless:{version}
```

For example we could see the following images for Resolute base images:

- `paketobuildpacks/ubuntu-resolute-builder:latest`
- `paketobuildpacks/ubuntu-resolute-builder-buildpackless:1.2.3`

This choice follows the same pattern as with Noble builders.

Notably, this naming convention can extend to other linux distributions.
For instance, builders based on UBI base images could be tagged `paketobuildpacks/ubi-10-builder:1.2.3`.

This naming convention does **NOT** include the architecture variant of the
images stored in each image repository. This is consistent with Paketo's
approach to multi-architecture base images support, as described in
[Stack RFC 0003: Stack Descriptor](../stacks/0003-stack-descriptor.md).

Each builder Docker Hub repository should include a README that outlines the builders and
base images that are available including links to each other repository (including
base images repositories).

## Implementation

### GitHub Repositories

The variants should be checked into one new builder repository that uses the
same automation as the [existing Paketo builders](https://github.com/paketo-buildpacks/github-config/tree/main/builder).
This repository should be named:

- `ubuntu-resolute-builder`

## Prior Art

- `ubuntu-noble-builder` repository

## Unresolved Questions and Bikeshedding

- none
