# Stacks based on Ubuntu 2022.04: Jammy Jellyfish

## Summary

A set of stacks based on the Ubuntu 2022.04 LTS (Jammy Jellyfish) release base
image should be developed, released, and maintained by the Stacks subteam. Like
the existing Bionic stacks, these new stacks should come in "full", "base", and
"tiny" variants with similar, if not identical, sets of packages pre-installed.

## Motivation

Ubuntu provides a long-term-support (LTS) release every 2 years in April. These
releases are supported by Canonical for 5 years. The current Bionic base image,
first released in April 2018, will therefore be going out of support at the end
of March 2023. In order to ensure that Paketo continues to provide a supported
Ubuntu-based stack for our users, we should produce a new set of stack images,
based on Jammy, alongside the current Bionic stacks.

## Detailed Explanation

### Variants

The Jammy stack will be delivered in 3 variants that align to those already
offered in the Bionic stack. The variants will be called `base`, `full`, and
`tiny` just as they are in the Bionic stack. Each should be developed to offer
roughly the same set of OS-level package support as their Bionic equivalent.

### Stack IDs

Stack IDs will be given to each variant of the stack as follows:

* Base: `io.buildpacks.stacks.jammy`
* Full: `io.buildpacks.stacks.jammy`
* Tiny: `io.buildpacks.stacks.jammy.tiny`

### User IDs

These stacks will differ from Bionic with regards to their UID definitions.
Each variant will ensure that the UID for the `build` phase is different than
the `run` phase. This change will align more closely with the
[recommendations](https://github.com/buildpacks/rfcs/blob/main/text/0085-run-uid.md)
outlined in the Buildpacks Specification.

### "Intermediate" Images

The current Bionic stack is also shipped alongside an "intermediate" or "base"
image that included all the packages, but is not decorated with the extra
CNB-specific metadata. The thought going back was that this type of image would
allow third-parties to more easily build a stack as they could simply extend
upon the "intermediate" image.

In order to simplify the stack offering going forward, we will no longer ship
this "intermediate" image. Users wishing to extend the stack can simply build
on top of the singular stack image as they would for any other type of
container image workflow.

### Image Naming and Tagging

The stacks will name and tag their release images with the following pattern:

```
paketobuildpacks/{phase}-jammy-{variant}:{version}
```

For example we could see the following images for Jammy stacks:

* `paketobuildpacks/build-jammy-base:latest`
* `paketobuildpacks/run-jammy-tiny:1.2.3`

This choice is different than the choice made with Bionic to better align the
image repository references with their logical stack definition. This means
that, with this naming scheme, it will be much more reasonable to understand
what is stored at the repository reference
`paketobuildpacks/run-jammy-base:latest`.

Each stack repository should include a README that outlines the stacks that are
available including links to each other repository allowing users to discover
the stack variants available from any of the stack repository pages.

#### Implications for Bionic

The benefits of this naming format should also be extended to the Bionic
stacks. This will help with consistency for stack consumers. However, we will
need to still produce images that conform to the existing naming format as
renaming these images is a breaking change that would surprise users.

### SBOM

This stack will **NOT** include an SBOM of the form outlined in Stacks
[RFC0001](https://github.com/paketo-buildpacks/rfcs/blob/main/text/stacks/0001-stack-package-metadata.md).
This choice is to ready ourselves to adopt whatever Stack SBOM functionality is
specified by the Cloud Native Buildpacks project while ensuring we don't
perpetuate the use of our own format for the entirety of this stack's support
lifetime.

This stack will adopt whatever official SBOM support is declared upstream by
the CNB project.

### Mixins

This stack will **NOT** include mixins declared through the
`io.buildpacks.stack.mixins` image label. This API is being superseded in the
upstream CNB project with this
[RFC](https://github.com/buildpacks/rfcs/blob/main/text/0096-remove-stacks-mixins.md).
In preparation for this, and to ensure we don't perpetuate a deprecated API,
the Jammy stacks will no longer include this label in their metadata.

## Rationale and Alternatives

We should at least discuss what it would mean to provide a Debian stack. There
are [LTS releases](https://wiki.debian.org/LTS) for Debian, but they follow a
different lifecycle and may not provide enough overlap to allow end-users to
migrate completely.

## Implementation

After the [final
release](https://discourse.ubuntu.com/t/jammy-jellyfish-release-schedule/23906)
date on April 21, 2022, we can release our official stack versions.

### Repositories

The Stacks subteam will create 3 new repos for Jammy:

* `jammy-base-stack`
* `jammy-full-stack`
* `jammy-tiny-stack`

Each of these repos will contain the configuration for its variant of the stack
as well as the releases and their related artifacts.

## Prior Art

* [`stacks`](https://github.com/paketo-buildpacks/stacks)
* [`base-stack-release`](https://github.com/paketo-buildpacks/base-stack-release)
* [`full-stack-release`](https://github.com/paketo-buildpacks/full-stack-release)
* [`tiny-stack-release`](https://github.com/paketo-buildpacks/tiny-stack-release)

## Unresolved Questions and Bikeshedding

* What does this mean for builders?
