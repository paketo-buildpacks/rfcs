# Base Images based on Ubuntu 2026.04: Resolute Raccoon

## Summary

A set of base images based on the Ubuntu 2026.04 LTS (Resolute Raccoon) release base
image should be developed, released, and maintained by the Stacks team. Like
the existing noble base images, these new base images should come in "build", "run", "run-tiny", and
"run-static" variants with similar, if not identical, sets of packages pre-installed.

If the package set is not identical, it would be due to changes in Ubuntu packages. The goal from the Paketo perspective is to have a functionally equivalent image from release to release.

## Motivation

Ubuntu provides a long-term-support (LTS) release every 2 years in April. These
releases are supported by Canonical for 5 years. The current jammy base image,
first released in April 2022, will therefore be going out of support at the end
of April 2027. In order to ensure that Paketo continues to provide supported
Ubuntu-based base images for our users, we should produce a new set of base images,
based on Resolute, alongside the current Noble base images.

## Detailed Explanation

### Variants

The Resolute base images will be delivered in 4 variants that align to those already
offered in the Noble base images. The variants will be called `build`, `run`, `run-tiny` and
`run-static` just as they are in the Noble base images. Each should be developed to offer
roughly the same set of OS-level package support as their Noble equivalent.

### Stack IDs

Stack IDs will be given to each variant of the base images as follows:

* Build: `io.buildpacks.base.images.resolute`
* Run: `io.buildpacks.base.images.resolute`
* Run tiny: `io.buildpacks.base.images.resolute.tiny`
* Run static: `io.buildpacks.base.images.resolute.static`

### User IDs

These base images will differ from Jammy with regards to their UID definitions.
Each variant will ensure that the UID for the `build` phase is different than
the `run` phase. This change will align more closely with the
[recommendations](https://github.com/buildpacks/rfcs/blob/main/text/0085-run-uid.md)
outlined in the Buildpacks Specification.

### Image Naming and Tagging

The base images will name and tag their release images with the following pattern:

```
paketobuildpacks/ubuntu-resolute-{variant}:{version}
```

For example we could see the following images for Resolute base images:

* `paketobuildpacks/ubuntu-resolute-build:latest`
* `paketobuildpacks/ubuntu-resolute-run:latest`
* `paketobuildpacks/ubuntu-resolute-run-tiny:latest`
* `paketobuildpacks/ubuntu-resolute-run-static:latest`

* `paketobuildpacks/ubuntu-resolute-build:1.2.3`
* `paketobuildpacks/ubuntu-resolute-run:1.2.3`
* `paketobuildpacks/ubuntu-resolute-run-tiny:1.2.3`
* `paketobuildpacks/ubuntu-resolute-run-static:1.2.3`

Each base image repository should include a README that outlines the base images that are
available.

### Mixins

These base images will **NOT** include mixins declared through the
`io.buildpacks.stack.mixins` image label. This API is being superseded in the
upstream CNB project with this
[RFC](https://github.com/buildpacks/rfcs/blob/main/text/0096-remove-stacks-mixins.md).
In preparation for this, and to ensure we don't perpetuate a deprecated API,
the Resolute base images will no longer include this label in their metadata.

## Implementation

After the [final release](https://documentation.ubuntu.com/release-notes/26.04/schedule/)
date on April 23, 2026, we can release our official base images versions.

### Repositories

The Stacks subteam will create 1 new repo for Resolute under Paketo buildpacks organization:

* `ubuntu-resolute-base-images`

This repo will contain the configuration for its variant of the base images
as well as the releases and their related artifacts.

## Prior Art

* [ubuntu-noble-base-images](https://github.com/paketo-buildpacks/ubuntu-noble-base-images)
* [ubi-10-base-images](https://github.com/paketo-buildpacks/ubi-10-base-images)

## Unresolved Questions and Bikeshedding

* N/A
