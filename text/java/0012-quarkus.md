# Quarkus Buildpack

## Summary
Provide a Quarkus Buildpack which will be part of the order groups for `paketo-buildpacks/java`, `paketo-buildpacks/java-azure`, and `paketo-buildpacks/java-native-image`.
The primary purpose of this buildpack is to set environment variables for the `paketo-buildpacks/maven` and `paketo-buildpacks/native-image` buildpacks. 

Building a Quarkus application is presently possible but requires setting multiple environment variables to properly configure the buildpacks. This proposed buildpack will enable users to build Quarkus applications without additional configuration.

Proof of concept could be found at: [quarkus-bp][b]

[b]: https://github.com/matejvasek/quarkus-bp

## Motivation
While building Quarkus application is already possible it's unnecessarily complicated.
The developer have to set 2 to 4 environment variables which is not obvious.

It should be as easy as just running: 
```sh
pack build my-img -B quay.io/mvasek/builder:base --env BP_NATIVE_IMAGE=1
```
instead of:
```sh
pack build my-img -B quay.io/mvasek/builder:base \
  --env BP_NATIVE_IMAGE=1 \
  --env "BP_MAVEN_BUILD_ARGUMENTS=package -DskipTests=true -Dmaven.javadoc.skip=true -Dquarkus.package.type=native-sources" \
  --env "BP_MAVEN_BUILT_ARTIFACT=target/native-sources/*" \
  --env "BP_NATIVE_IMAGE_BUILD_ARGUMENTS_FILE=native-image.args" \
  --env "BP_NATIVE_IMAGE_BUILT_ARTIFACT=*-runner.jar"

```

## Detailed Explanation
The [Quarkus Buildpack][b] will be moved into the paketo-buildpacks Github organization and added to the Java sub-team. Maintenance for this buildpack will be provided by the Java subteam.

The following changes will be made:
* [Quarkus Buildpack][b] moved to Paketo Buildpacks org
* The Buildpack will be published to `gcr.io/paketo-buildpacks/quarkus`
* The Buildpack will be added to the `paketo-buildpacks/java`, `paketo-buildpacks/java-azure`, and `paketo-buildpacks/java-native-image` meta-buildpacks groups right before the `paketo-buildpacks/maven` and `paketo-buildpacks/gradle` buildpacks.

[b]: https://github.com/matejvasek/quarkus-bp

## How the buildpack works

The buildpack will set following environment variables:
* `BP_MAVEN_BUILD_ARGUMENTS`
* `BP_MAVEN_BUILT_ARTIFACT`
* `BP_NATIVE_IMAGE_BUILD_ARGUMENTS_FILE` (native build only)
* `BP_NATIVE_IMAGE_BUILT_ARTIFACT` (native build only)

The detect phase checks if:
* The `pom.xml` specifies usage of Quarkus plugin.
* None of the above environment variables is already set.

If both conditions are met this buildpack will participate.
The second condition is there to allow users to manually set the environment variable should they need it.

The build phase sets the aforementioned variables with respect to the `BP_NATIVE_IMAGE` environment variable.

**NOTE:** This is implementation for `Maven` only. For `Gradle` further work will be required in future.

## Rationale and Alternatives
Alternative approach could be to create much less lightweight buildpacks
which would do all steps carried out by the `maven`, `executable-jar` and `native-image` buildpacks
in on single Quarkus Buildpack.

This would allow better control over build: better enablement for various package types (i.e. other than `fast-jar`).
However this is not of much importance since `fast-jar` should work for majority of users.
Downside is that it is more complicated to implement, and it would lead to duplication (e.g. duplicating maven BP functionality).

Another approach could be to have two Quarkus buildpacks: one pre maven/gradle build and one post build.
With these we might be able to handle various build types (fast/legacy/uber jar).
Again downside is that it is more difficult to implement and ability to chose packaging is not priority.

## Implementation

This buildpack will be adopted by the Java Buildpacks team and transferred to the `paketo` GitHub organization as described in the [Detailed Explanation](#detailed-explanation) section above.

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

N/A
