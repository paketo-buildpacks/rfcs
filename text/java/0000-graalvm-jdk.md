# Introduce new buildpacks for the latest GraalVM release

## Summary

The existing [`graalvm` buildpack](https://github.com/paketo-buildpacks/graalvm) will be clarified to indicate that it is the GraalVM Community buildpack. We cannot change the id, but we will update the README and metadata to clarify this point.

In addition, to support the new [Oracle GraalVM](https://www.oracle.com/java/graalvm/) distribution we will modify the [Oracle Buildpack](https://github.com/paketo-buildpacks/oracle) to include support for Oracle's GraalVM.

## Motivation

There are multiple motivations for this RFC:

1. The [`graalvm` buildpack](https://github.com/paketo-buildpacks/graalvm) only supports GraalVM Community Edition. Since this is only one of many GraalVM distributions (Community Edition, Oracle GraalVM, Liberica NIK, Mandrel, ...), it makes sense to adjust the name and the README of the buildpack, so that it is clear to users which distribution the buildpack includes (Community Edition).
2. The latest GraalVM release has dropped the GraalVM version in favor of the Java version, which may simplify the implementation and maintenance of the buildpack.
3. Due to the [alignment with OpenJDK](https://www.graalvm.org/2022/openjdk-announcement/), GraalVM is becoming more and more a standard JDK with Native Image support. The GraalVM Updater will be [deprecated in the GraalVM for JDK 21 release](https://github.com/oracle/graal/issues/6855) and removed in the future.
4. Oracle has [introduced Oracle GraalVM](https://medium.com/graalvm/a-new-graalvm-release-and-new-free-license-4aab483692f5), a new and free GraalVM distribution that provides advanced features including G1 GC, SBOM, as well as performance and size optimizations. A new buildpack for Oracle GraalVM will, for example, allow Spring users to build more efficient and secure microservices.


## Detailed Explanation

This RFC proposes to address the items listed under Motivation as follows:

1. Introduce a new `graalvm-community` and clarify that it includes GraalVM Community Edition in the README. The `graalvm` buildpack is kept for backward compatibility but is no longer maintained.
2. The new `graalvm-community` build will only support GraalVM for JDK 17 and later, following the new versioning scheme. Older GraalVM releases are still available via the deprecated `graalvm` buildpack.
3. Investigate whether the `graalvm-community` buildpack can further be simplified and aligned with the [Java buildpacks](0016-alternate-jvms-in-java-buildpack.md).
4. Add a new `graalvm-oracle` buildpack that supports Oracle GraalVM and works just like the `graalvm-community` buildpack.

## Rationale and Alternatives

Alternatively, the existing `graalvm` buildpack could be reworked and extended with support for Oracle GraalVM. For this, we would need to offer an environment variable such as `$BP_DISTRIBUTION` for users to select a specific GraalVM distribution. However, that would be somewhat inconsistent with the `bellsoft-liberica` buildpack, which also includes a GraalVM distribution. Having separate buildpacks for different GraalVM distributions is also more consistent with the [Java buildpacks](0016-alternate-jvms-in-java-buildpack.md).

## Implementation

First, we plan to fork the [`graalvm` buildpack](https://github.com/paketo-buildpacks/graalvm) to create a new `graalvm-community` buildpack and update its README. This way, we don't break existing users of the `graalvm` buildpack and allow them to upgrade to either the `graalvm-community` buildpack or the new `graalvm-oracle` buildpack.

Second, we create a new `graalvm-oracle` buildpack that pulls Oracle GraalVM instead of GraalVM Community Edition using the [Script Friendly URLs](https://www.oracle.com/java/technologies/jdk-script-friendly-urls/). The goal is to share as much code as possible between the two buildpacks to keep maintenance costs to a minimum. For this, we may need to create an "abstract" buildpack on which both `graalvm-community` and `graalvm-oracle` can be based.

Finally, we add a deprecation notice to the README of the `graalvm` buildpack and archive the repository.
