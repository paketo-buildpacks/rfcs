# UPX Support

## Summary

Introduce an UPX buildpack. This buildpack will provide the `upx` binary should any buildpacks want to use it. The `upx` binary can be used to compress executables by buildpacks producing binary executables and reduce binary sizes by often one half.

The UPX buildpack would be maintained by the existing [Utilities team](https://github.com/orgs/paketo-buildpacks/teams/utilities). It uses libpak & libcnb.

## Motivation

There are a number of buildpacks where compressing generated executables can help to generate smaller images. For example, Java native image binaries when using the tiny builder can easily become larger than the entire rest of the image. Being able to compress a Java native image binary will help to reduce the image size in a significant way.

This may be desirable with other buildpacks as well, such as the Go and Rust families, where good compression rates are also feasible.

## Detailed Explanation

1. A UPX buildpack has been developed. It will be contributed to Paketo.
2. Other buildpacks wishing to compress binaries will opt-in by doing the following:
   1. At detect time, require `upx`.
   2. At build time after generating a binary, run `upx -q -9 <binary>` to compress the binary. This replaces the binary in-place with the compressed version.
3. The native-image buildpack will implement this opt-in behavior.

It is recommended that buildpacks which opt-in to using `upx`, make using `upx` optional with a default of disabled. This is because there is presently a known issue that causes a SEGFAULT when running a `upx` compressed binary on a Mac M1 Laptop running buildpacks under amd64 emulation. Defaulting to off provides for the largest compatibility.

## Rationale and Alternatives

1. `upx` could be added to the various build images. This is an easy option, but increases the build image size. It also does not allow a buildpack to guarantee that UPX is present, as some users have customized build images.
2. `upx` could be added into individual buildpacks, such as directly in the native-image buildpack. Given that there are likely other buildpacks which can make use of UPX, this requires repetition of code across multiple buildpacks.

## Implementation

The new UPX buildpack will participate all the following conditions are met

* Another buildpack requires `upx`

When conditions are met, the buildpack will do the following:

* Contributes UPX to a layer marked `build` and `cache` with command on `$PATH`

Buildpacks that wish to opt-in, simply need to indiate that they require `upx` at detection time. Then `upx` should be present on the path at build time and these buildpacks can run `upx -q -9 <binary>` to compress a binary.

The UPX buildpack would need to be added to the order group for any language family that wishes to use `upx`. It needs to be added prior to the buildpack that is going to require `upx`. For example, the native-image buildpack will require UPX, so UPX needs to be listed in the order groups prior to native-image.

## Prior Art

None

## Unresolved Questions and Bikeshedding

None
