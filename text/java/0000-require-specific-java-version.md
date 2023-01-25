# Require a specific version of a `JDK` or `JRE` in the buidplan

## Summary

Currently, buildpacks can require a `jre` or `jdk` in a buildplan. But the actual version of this dependency is completely up to the buildpack providing the dependency (e.g. [bellsoft-liberica](https://github.com/paketo-buildpacks/bellsoft-liberica)).

The [Buildpack Interface Specification](https://github.com/buildpacks/spec/blob/main/buildpack.md#build-plan-toml-requiresversion-key) allows to specify `requires.metadata.version`to request a specific version of the dependency.

## Motivation

When some `buildpack` knows more information about the required java version (e.g. as part of the `pom.xml`), it still relys on the providing buildpack to pick the right version or for the user to request it. This could ease the usage of `buildpacks` for java applications.

## Detailed Explanation

A buildplan would look like

```toml
[[requires]]
name = "jdk"

[requires.metadata]
version = "17"
```

This is requesting a `jdk` in version 17.

## Rationale and Alternatives

Otherwise the default version would be chosen (which is 11) or the user would have to specify the version via `BP_JRE_VERSION`.

Currently, `libjvm` alone is deciding what version of java dependency is provided. This feels strange because `libjvm` does not even know why the java dependency was requested in the first place.

## Implementation

If the user requests a specific version via `BP_JRE_VERSION`, that version should always be taken.

## Prior Art

The same is possible for choosing the `node` version in the [node-engine buildpack](https://github.com/paketo-buildpacks/node-engine)

## Unresolved Questions and Bikeshedding

* How to handle possible conflicts?
* Is this adding too much complexity?
