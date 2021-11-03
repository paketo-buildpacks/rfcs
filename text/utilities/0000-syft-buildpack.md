# Syft Buildpack

## Summary

Introduce a Syft buildpack. This buildpack will provide the [`syft` binary](https://github.com/anchore/syft) should any buildpacks want to use it. The `syft` CLI is a tool and library for generating a Software Bill of Materials from container images and filesystems.

The Syft buildpack would be maintained by the existing [Utilities team](https://github.com/orgs/paketo-buildpacks/teams/utilities). It uses libpak & libcnb.

## Motivation

It can be used by buildpacks to scan and generate both CycloneDX and SPDX listings of layers for compliance with [Buildpacks RFC #95](https://github.com/buildpacks/rfcs/blob/main/text/0095-sbom.md).

## Detailed Explanation

1. A Syft buildpack has been developed. It will be contributed to Paketo.
2. Other buildpacks wishing to compress binaries will opt-in by doing the following:
   1. At detect time, require `syft`.
   2. At build time after generating a binary, run `syft packages -q -o <format> "dir:<path>"` to scan a directory. Valid formats are `json`, `text`, `table`, `cyclonedx`, `spdx-tag-value`, and `spdx-json`.

## Rationale and Alternatives

1. `syft` could be added to the various build images. This is an easy option, but increases the build image size. It also does not allow a buildpack to guarantee that Syft is present, as some users have customized build images.
2. `syft` could be added into individual buildpacks, such as directly in the maven buildpack. Given that there are likely other buildpacks which can make use of Syft, this requires repetition of code across multiple buildpacks.

## Implementation

The new Syft buildpack will participate all the following conditions are met

* Another buildpack requires `syft`

When conditions are met, the buildpack will do the following:

* Contributes Syft to a layer marked `build` and `cache` with command on `$PATH`

Buildpacks that wish to opt-in, simply need to indiate that they require `syft` at detection time. Then `syft` should be present on the path at build time and these buildpacks can run it.

The Syft buildpack would need to be added to the order group for any language family that wishes to use `syft`. It needs to be added prior to the buildpack that is going to require `syft`, which would likely require it to be very early in the order group. For example, the maven buildpack will require Syft, so the Syft buildpack needs to be listed in the order groups prior to maven.

## Prior Art

* We include other utility tools in this manner, through a buildpack, like UPX and Watchexec

## Unresolved Questions and Bikeshedding

None
