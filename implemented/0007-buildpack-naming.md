# Paketo Buildpack Naming

## Summary

All Paketo buildpacks should be named in a consistent manner. Specifically,
they should include a "Paketo" prefix before their identifier and include a
"Buildpack" suffix.

## Motivation

Providing a buildpack name that indicates that these buildpacks are part of the
Paketo organization will help users to identify the provenance of the
buildpacks running on their platform more easily. There are already offerings
for buildpacks in similar runtimes from other organizations. Indicating that a
buildpack comes from the Paketo organization will help to clear up any
ambiguity.

## Detailed Explanation

Taking an example of the "Node Engine" buildpack, the proper name would be
"Paketo Node Engine Buildpack". This name should appear in the `buildpack.name`
field within the `buildpack.toml` file.

## Rationale and Alternatives

The obvious alternative is to let buildpack maintainers name their buildpacks
independently. This will likely lead to confusion and is not recommended.

## Implementation

Any buildpacks that do not follow the rules outlined above should be renamed to
align with this RFC.

## Prior Art

There are already an existing set of buildpacks within the Paketo community
that conform to this naming pattern. Here is a subset of examples:

- [Paketo Java Buildpack](https://github.com/paketo-buildpacks/java/blob/81ba7f4a1f1ba6b12ab4a1ccc97a8770e0b8023e/buildpack.toml#L19)
- [Paketo Lein Buildpack](https://github.com/paketo-buildpacks/leiningen/blob/ce47f6864c6179efa44ad6247f353508c014b6d0/buildpack.toml#L5)
- [Paketo Maven Buildpack](https://github.com/paketo-buildpacks/maven/blob/b3045bd346f696b3fe22f7942e20b4d4ada3eb57/buildpack.toml#L19)
- [Paketo Spring Boot Native Image Buildpack](https://github.com/paketo-buildpacks/spring-boot-native-image/blob/164dfa4e115834241e07b684c328e40b2afcec5d/buildpack.toml#L19)
