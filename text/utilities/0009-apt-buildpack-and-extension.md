# APT Buildpack and Extension

## Summary

Officially introduce an APT buildpack. This buildpack will allow users to install additional packages to an existing Ubuntu / Debian based stack.

This RFC also targets an APT CNB extension; to allow for a better architectural design.

## Motivation

There are multiple times users reported the need for external dependencies, as in dependencies not provided by their app, but rather by the system package manager.

Such examples are:

* Application that relies on FFMpeg at runtime to encode / decode video.
* Application that relies on LibreOffice binaries to generate spreadsheets, etc.

Having a buildpack that allows people to install Ubuntu / Debian packages would allow them to not maintain their own stacks, with all the maintenance burden that it implies.

## Detailed Explanation

1. See prior art to see how it was always created by the community

2. The work needed to have an initial Paketo APT buildpack would be to have an official fork into `paketo-buildpacks` and integrate it with existing CI and release mechanisms

## Rationale and Alternatives

1. A user can create their own stack, or provide their own `run-image` - but in both those cases, they will need to maintain those images.
2. A user could integrate the required libs or binaries for their apps from their source code; not ideal though, and certainly not architecture agnostic (arm64 / x86_64)

## Implementation

The implementation of the buildpack would be a fork of `Prior Art`

### Example

See: https://github.com/fagiani/apt-buildpack?tab=readme-ov-file#usage

## Prior Art

We can mention:

* https://github.com/fagiani/apt-buildpack ; completely built using shell scripts, but pretty stable and maintainable as many forks were created upon it, including, but not limited to:
* https://github.com/dmikusa/apt-buildpack and many other:
* https://github.com/fagiani/apt-buildpack/network

## Unresolved Questions and Bikeshedding

None
