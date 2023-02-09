# Allow users to consume pre-release depedencies

## Summary

Each buildpack has a list of dependencies that can be provided. This list could also contain pre-releases so that the buildpack can provide early access to some dependencies.

## Motivation

Some dependencies (e.g. `sap-machine`) provide pre-releases for their releases. By allowing the user to use them via buildpacks, the upcoming version could already be validated.

## Detailed Explanation

1. Add a `preview` field to `metadata.dependecies` in `buildpack.toml`

    ```toml
    [[metadata.dependencies]]
        cpes = ["cpe:2.3:a:oracle:jdk:19.0.2:*:*:*:*:*:*:*"]
        id = "jdk"
        name = "SapMachine JDK"
        preview = true
        purl = "pkg:generic/sap-machine-jdk@19.0.2?arch=amd64"
        sha256 = "e7b27e8b5b4ca2a172b0a6299eaba9cf7e0cceeea11aeb37fd3ff1ef71cff018"
        stacks = ["io.buildpacks.stacks.bionic", "io.paketo.stacks.tiny", "*"]
        uri = "https://github.com/SAP/SapMachine/releases/download/sapmachine-19.0.2%2B1/sapmachine-jdk-19.0.2-ea.1_linux-x64_bin.tar.gz"
        version = "19.0.2+1"
    ```

2. Add `BP_ALLOW_PREVIEW_VERSIONS` enviroment variable.
   Possible values:
   - unset / empty: No preview versions
   - `true`: Use preview version whereever availalbe
   - comma separated list: Use preview version for named dependencies, e.g. `node,npm` or `jvm`

## Rationale and Alternatives

- **Do nothing**

  We could stick to the status quo (pre-releases can't be consumed via buildpacks).

- **Fetch latest preview in buildpack**

  We could fetch the latest preview versions "on the fly" within the buildpack.
  On the one hand, this would decouple the release process of the buildpack from its dependencies and make pre-releases availabe to buildpack users as soon as they get released upstream.
  On the other hand, it makes sha-sum validation impossible. As the comsumption of pre-releases is not meant for productive use, supply chain attacks might be less of a concern.

- **Implement buildpack specific solution**

  For every buildpack that would profit from providing pre-releases, the respective maintainers could implement it however they see fit.
  In the long run a common pattern may arise naturally.

- **Implement only for java dependencies**

  All java dependencies (`jdk`, `jre`) could be consumed as pre-releases and this would not influence other buildpacks.

Although this is not valid for all buildpacks (e.g. the dependencies do not have pre-releases), it could add value for some. And if a buildpack wants to provide this, the implementations would be very similar. The handling of dependencies is done in `libpak` or `packit`.

## Implementation

- **Add pre-releases to `buildpack.toml`**

  Each buildpack can decide if pre-releases should be added. For example `github-release-dependency` could be changed to add an additional input and add releases that are marked with `pre-release` on github if requested. This should probably be handled generically by `libpak` and `packit`.

- **Use of pre-releases for a dependecy**

  By default pre-release versions of dependencies should be ignored, but if enabled (e.g. an environment variable, see [Detailed Explanation](#detailed-explanation)) the versions should be considered.

## Prior Art

## Unresolved Questions and Bikeshedding

- How to bump the version of the buildpack if a new pre-release version is added (e.g. major version)?
