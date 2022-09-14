# Create static stack

## Summary

The Paketo stacks maintainers should create and maintain a stack (called
"static") that can run statically-linked applications (e.g. Go, Rust).
The Paketo builder maintainers will make a buildpackless builder for this
stack.

Additionally, the golang buildpack should gain support for this new static
stack, both in order to provide a useful experience to Go application
developers as well as to enable integration tests for this new stack.

## Motivation

Some applications consist of a single
[statically-linked](https://en.wikipedia.org/wiki/Static_library) executable.
This is most common in golang, but is also often utilized in rust. It is also
common in languages/toolchains not supported by Paketo like C/C++. These
statically-linked binaries can be run on a minimally-modified empty container
image (AKA "static" image) with few-to-no packages/libraries. Static images
are a common choice of container image for statically-linked executables as it
minimizes the size (in MB) of the image as well as the number of installed
packages - in turn reducing the surface area for security issues.

Currently, in order to build these statically-linked applications using Paketo
buildpacks (and aiming for the smallest possible resultant run image) users
must either opt for the [tiny
stack](https://github.com/paketo-buildpacks/jammy-tiny-stack) or build their
own static stack. We have evidence of users doing both of these things.
Neither are satisfactory to users, however, as the tiny stack contains more
packages than is necessary for those applications, and users would prefer not
to maintain their own stacks if Paketo is willing and able to do so.

Perhaps most importantly, we are [considering adding more packages to the tiny
stack](https://github.com/paketo-buildpacks/rfcs/pull/231/files), and the
biggest objection to that proposal is that it will further increase the size
and surface area of the tiny image for statically-linked binaries. This could,
in-turn, make Paketo less attractive for developers of these applications.

Creating a static stack will decouple these use cases, allowing us to tailor
the tiny stack to applications which want more packages, while also providing a
better experience for statically-linked binaries.

## Detailed Explanation

### Repository/Image Location

We will create a new Github repository at
`paketo-buildpacks/jammy-static-stack` and a new pair of images on Dockerhub
at `paketobuildpacks/build-jammy-static` and
`paketobuildpacks/run-jammy-static`.

We will adopt the tag system used for Jammy - specifically semver (i.e.
'X.Y.Z') and 'latest' tags.

The builders team will create a new Github repository at:
`paketo-buildpacks/builder-jammy-buildpackless-static` similar to existing
buildpackless builders.

### Stack ID

We propose creating a new stack ID: `io.buildpacks.stacks.jammy.static`.
This does not require approval from the upstream Cloud-Native Buildpacks project.

### Image Contents

The static stack run image will contain the `tzdata` and `ca-certificates`
packages, the standard CNB/Paketo metadata (including users and /etc/passwd
entries), and nothing else. These two packages are often provided in static
images as they are small and have minimal security risk.

The build image will contain the same packages as the tiny stack (probably with
the addition of the packages proposed in [the tiny packages
RFCS](https://github.com/paketo-buildpacks/rfcs/pull/231/files)).

In practice, the static stack will look like a stripped-down version of the
existing tiny stack, with most packages removed and minor tweaks to the
metadata to support the change in name, support URL, etc.

### Automation

We will leverage the existing stack automation that all the Paketo stacks use.
This includes checking for USNs on a regular cadence and automatically pushing
new releases to Dockerhub as they are created.

Although there are few CVEs for the `tzdata` and `ca-certificates` packages,
and hence the run image will be updated infrequently, we want to ensure the
build image is also kept up to date with CVE fixes for all of its packages.

Also, on a practical note, leveraging the existing automation that is used in
all other stacks is simpler for the stacks maintainers than creating a new
system just for this stack.

### Golang Buildpack

We will add support for this new stack in the golang buildpack. This will
enable the following:

1. Golang application developers can utilize this new stack out-of-the-box,
   without having to modify the Golang buildpack to support this new stack.
1. The static stack can use the Golang buildpack for its integration tests.
   This will enable meaningful end-to-end integration tests for this stack. We
   want to be able to build and run a test application during the stack
   integration test, and golang is the best choice for this.

## Rationale and Alternatives

1. We could not create a static stack at all, and continue adding more
   packages to the tiny stack. This would likely be unaceptable to developers
   of applications that can be statically-linked, and will likely turn them
   away from the Paketo project. We have already heard feedback that the tiny
   stack is larger than some golang developers would like and is already a
   reason not to adopt Paketo Buildpacks.
1. We could keep the tiny stack as-is - not consider adding further packages to
   it. This would satisfy current users at the expense of making the tiny stack
   more useful. It also does not make Paketo more attractive to users who find
   the tiny stack is already too large for their needs.
1. We could create the new stack but not add support in the Golang buildpack.
   This renders the stack effectively useless for Paketo consumers, as no
   Paketo buildpacks would support it without modifying a buildpack and
   re-packaging it.
1. We could base the stack on Ubuntu 18.04 (Bionic) instead of (or as well as)
   Ubuntu 22.04 (Jammy). This adds cost and complexity for the stacks
   maintainers, and provides limited benefit to developers as the run image
   would be almost identical. Additionally, Bionic will be end-of-life in April
   2023 so this proposed stack would only be present for a few months.

## Implementation

1. Create a new Github repository at: `paketo-buildpacks/jammy-static-stack`
1. Copy most of the existing contents from `paketo-buildpacks/jammy-tiny-stack` into this repository.
1. Update metadata (e.g. stack name, Support URL, etc).
1. Remove all packages from the `run` image package list except `tzdata` and `ca-certificates`.
1. Ensure the integration tests statically links the golang test application.
1. Run the automation, which will automatically publish an image.

## Prior Art

Some Paketo consumers already use an image with minimal packages installed in
commercial/internal environments. Their feedback is that a static image with
`tzdata` and `ca-certificates` packages is sufficient for their use-cases.

Various literature (e.g.
[this](https://blog.baeke.info/2021/03/28/distroless-or-scratch-for-go-apps/),
and
[this](https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324)
describe the use of "static" images for statically-linked golang applications,
with or without the `tzdata` and `ca-certificates` packages.

## Unresolved Questions and Bikeshedding

* Should we skip `ca-certificates` given that users can use the
  [ca-certificates
  buildpack](https://github.com/paketo-buildpacks/ca-certificates)? If so,
  would it be too much of a burden for users to use this buildpack to add
  certificates that would be specified in the `ca-certificates` package?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
