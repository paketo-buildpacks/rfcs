# Builders based on Ubuntu 2022.04: Jammy Jellyfish

## Summary

A set of stacks based on the Ubuntu 2022.04 LTS (Jammy Jellyfish) will be
maintained by Paketo, per stacks [RFC
0004](https://github.com/paketo-buildpacks/rfcs/blob/da3339d071ffed23c3cd1b374a6bfcefdea7ac70/text/stacks/0004-jammy-jellyfish.md).
Builders are an important way for Paketo users to consume stacks; they can be
used as an input to the `pack` CLI. Paketo should maintain a set of builders
that use the Jammy Jellyfish stacks.  They should be developed, released, and
maintained by the Builders subteam.  These new builders should come in "full",
"buildpackless-full", "base", "buildpackless-base",  "tiny", and
"buildpackless-tiny" variants.

## Motivation

Paketo [plans to support Jammy Jellyfish
stacks](https://github.com/paketo-buildpacks/rfcs/blob/da3339d071ffed23c3cd1b374a6bfcefdea7ac70/text/stacks/0004-jammy-jellyfish.md).
Paketo [builders](https://paketo.io/docs/concepts/builders/) are a common way
for Paketo users to consume Paketo stacks, buildpacks, and the Cloud Native
Buildpacks (CNB) lifecycle. In order for many Paketo users to get value from
Jammy Jellyfish stacks, we'll need to provide Jammy Jellyfish builders.

## Detailed Explanation

### Variants

The Jammy builders will be available in 6 variants that align to the existing
Bionic-based builders. These will be called:
- `jammy-full`
- `jammy-buildpackless-full`
- `jammy-base`
- `jammy-buildpackless-base`
- `jammy-tiny`
- `jammy-buildpackless-tiny`

The Jammy builders will eventually* contain corresponding sets of buildpacks to
their Bionic counterparts. Buildpackless builders will contain no buildpacks,
as described in the [Buildpackless Builders
RFC](https://github.com/paketo-buildpacks/rfcs/blob/da3339d071ffed23c3cd1b374a6bfcefdea7ac70/text/0030-buildpackless-builders.md).

\*Note: Some buildpacks (or the tools they install) may not yet be compatible
with the Jammy Jellyfish operating system. For instance, this is an [open
discussion](https://github.com/dotnet/core/issues/7038) for .NET Core. While
the Jammy builders should mirror existing Paketo builders as best as possible,
if buildpack or language support presents a blocker, it is acceptable to
release builders with best-effort subsets of the buildpacks supported by the
Bionic builders.

### Image Naming and Tagging

The builders will name and tag their release images with the following pattern:

```
paketobuildpacks/builder-{distro}-{builder-variant}:{version}
```

For example we could see the following images for Jammy stacks:

* `paketobuildpacks/builder-jammy-base:latest`
* `paketobuildpacks/builder-jammy-buildpackless-tiny:1.2.3`

This choice is different than the choice made with Bionic to better align the
image repository references with their associated builder repository. This
means that, with this naming scheme, it will be much more reasonable to
understand what is stored at the repository reference
`paketobuildpacks/builder-jammy-base:latest`.

Notably, this naming convention can extend to other linux distributions. For
instance, builders based on a UBI stack could be tagged
`paketobuildpacks/builder-ubi-base:1.2.3`.

This naming convention does **NOT** include the architecture variant of the
images stored in each image repository. This is because we intend to publish
multi-architecture builder images to the same image tags using [image manifest
lists](https://docs.docker.com/registry/spec/manifest-v2-2/). This is
consistent with Paketo's approach to multi-architecture stack support, as
described in [Stack RFC 0003: Stack
Descriptor](https://github.com/paketo-buildpacks/rfcs/blob/da3339d071ffed23c3cd1b374a6bfcefdea7ac70/text/stacks/0003-stack-descriptor.md).

Each builder DockerHub repository should include a README that outlines the builders and
stacks that are available including links to each other repository (including
stacks repositories) allowing users to discover the variants available from any
of the builder repository pages.

#### Implications for Bionic
##### Github Repositories
The existing (Bionic) buildpack repositories should be renamed to reflect the
naming order of jammy builders. For example, the `buildpackless-full-builder`
should be renamed `builder-bionic-buildpackless-full`.

When the Bionic operating system (and stacks) go out of support, these
repositories should be archived.

##### DockerHub repositories
The benefits of this naming format should also be extended to the Bionic
builders. This will help with consistency for builder consumers. However, we
will need to still produce images that conform to the existing naming format as
renaming these images is a breaking change that would surprise users.

This means we should push the existing builders to the tags where we already
push them, **and** should push them to tags like
`paketobuildpacks/builder-bionic-buildpackless-base:1.2.3`.

When the Bionic operating system (and stacks) go out of support, we should
**stop pushing any builders** to the legacy `paketobuildpacks/builder`
repository. The repository should be archived. From that point forward,
the`paketobuildpacks/builder-jammy-{variant}` repositories will be the only
sources of Paketo builders (until the next Ubuntu LTS OS becomes available).

## Rationale and Alternatives

- Once Bionic goes out of support, start pushing Jammy builders to the
  `paketobuildpacks/builder` repository
  - Benefits:
    - Provides a simple entrypoint builder repo for beginner Paketo users.
    - Does not require users to migrate
  - Drawbacks:
    - Requires Paketo to maintain 1 more DockerHub repo
    - The contents of the repo is ambiguous –one day, users pulling
      `paketo-buildpacks/builder:base` will start getting Jammy with little
      warning
- Don't publish the same 6 builder variants we provide for Bionic. For
  instance, don't provide buildpackless builders or don't provide an additional
  Full builder.
  - Benefits:
    - Paketo is responsible for fewer repositories on Github and DockerHub
    - An opportunity to drop support for builders whose user base is
      small/niche
  - Drawbacks:
    - Bulidpackless builders are very useful in integration testing for the
      Paketo core team
    - Users of buildpacks only available in the Full builder will have to
      choose between creating their own builder, extending the
      jammy-buildpackless-full builder, or the using Bionic builder
- Allow builder Github repository names to differ from their DockerHub
  counterparts'. Call builder Github repositories
  `paketo-buildpacks/jammy-buildpackless-base-builder`
  - Benefits:
    - Naming matches established Jammy Stack Github repository
      [convention](https://github.com/paketo-buildpacks/stacks/issues/133).
  - Drawbacks:
    - Github and Dockerhub naming difference may impact discoverability
		
## Implementation

### Github Repositories
The variants should be checked into 6 new builder repositories that use the
same automation as the [existing Paketo
builders](https://github.com/paketo-buildpacks/github-config/blob/7d5aefb45e0de146370978566e2af22a4bfbbe4d/builder).
These repositories should be named:
- `builder-jammy-full`
- `builder-jammy-buildpackless-full`
- `builder-jammy-base`
- `builder-jammy-buildpackless-base`
- `builder-jammy-tiny`
- `builder-jammy-buildpackless-tiny`

## Prior Art

## Unresolved Questions and Bikeshedding

