# OCI Image Annotations on Buildpacks

## Summary

All Paketo Buildpacks must have at least the following OCI image annotations with values as defined by the [OCI Image Format Specification's Pre-Defined Annotation Keys](https://github.com/opencontainers/image-spec/blob/v1.1.0/annotations.md#pre-defined-annotation-keys):
* `org.opencontainers.image.source`
* `org.opencontainers.image.revision`
* `org.opencontainers.image.title`
* `org.opencontainers.image.version`

The following additional annotation are recommended:
* `org.opencontainers.image.url`
* `org.opencontainers.image.description`

## Motivation

Knowing the origin and other metadata for a buildpack (which is an OCI image) is very helpful. Some examples of such use cases include finding release notes, user manuals, bug reporting procedures, and license information. Currently, it can be difficult to find the source control repository of a buildpack as that information is not available in a standard way.

The OCI Image Format Specification's Pre-Defined Annotation Keys provide a standardized way to discover additional information about an OCI image. Because these annotations are standardized and widely used, tools have come to use them. For example, [Snyk](https://snyk.io/blog/how-and-when-to-use-docker-labels-oci-container-annotations/) and [Renovate](https://github.com/renovatebot/renovate/blob/34.115.1/lib/modules/datasource/docker/readme.md use these annotations.

## Detailed Explanation

The annotations must have values complying with the OCI image format specification. The following example values are from [Paketo Buildpack for Java 13.0.1](https://github.com/paketo-buildpacks/java/releases/tag/v13.0.1):

* `org.opencontainers.image.source`: https://github.com/paketo-buildpacks/java
* `org.opencontainers.image.revision`: 09747b1df0a56aea74ce9b01af89df6feb1fc50a
* `org.opencontainers.image.title`: Paketo Buildpack for Java
* `org.opencontainers.image.version`: 13.0.1
* `org.opencontainers.image.url`: https://paketo.io/docs/howto/java
* `org.opencontainers.image.description`: A Cloud Native Buildpack with an order definition suitable for Java applications

## Rationale and Alternatives

Instead of standardizing the use of these annotations across all Paketo Buildpacks, each buildpack could add the annotations individually. However, that approach has significant consistency and maintainability concerns. Standardizing the annotations and implementing them consistently across all Paketo Buildpacks minimizes risk and maximizes utility.

## Implementation

When building the buildpack, the builder can get the values for the `org.opencontainers.image.source` and `org.opencontainers.image.revision` annotations from git. `org.opencontainers.image.source` is derived from the git origin and `org.opencontainers.image.revision` is the git commit ref.

The other annotation values come from `buildpack.toml` mapped to OCI annotations as follows:
* `name` -> `org.opencontainers.image.title`
* `version` -> `org.opencontainers.image.version`
* `homepage` (optional) -> `org.opencontainers.image.url`
* `description` (optional) -> `org.opencontainers.image.description`

## Prior Art

Many images are setting at least some of these OCI image annotations. Oftentimes, they are implemented using `LABEL` instructions in `Dockerfile`s or using arguments to the CLI tool used to build the image.
