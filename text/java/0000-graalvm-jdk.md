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

1. Update the README & buildpack metadata for the existing GraalVM buildpack to indicate it is specifically for the GraalVM Community release.
2. Update the [Oracle Buildpack](https://github.com/paketo-buildpacks/oracle) to support Oracle GraalVM. This will work just like what we have with the present Bellsoft Liberica buildpack, where the buildpack can provide a JVM and Native image tools.

For more details, please see the [proof of concept](https://github.com/paketo-buildpacks/rfcs/pull/294).

## Rationale and Alternatives

Alternatively, the existing `graalvm` buildpack could be reworked and extended with support for Oracle GraalVM. For this, we would need to offer an environment variable such as `$BP_DISTRIBUTION` for users to select a specific GraalVM distribution. However, that would be somewhat inconsistent with the `bellsoft-liberica` buildpack, which also includes a GraalVM distribution. Having separate buildpacks for different GraalVM distributions is also more consistent with the [Java buildpacks](0016-alternate-jvms-in-java-buildpack.md).

## Implementation

See the Details section. The implementation plan as well as a proof of concept PR are documented there.
