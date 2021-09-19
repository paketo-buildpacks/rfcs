# Paketo Buildpacks Oracle JDK Buildpack

## Summary

A [Oracle JDK Buildpack](https://github.com/eddumelendez/oracle-jdk) for supplying Oracle's distribution of OpenJDK has been created by [@eddumelendez][@eddumelendez]. It is built using common tooling (libpak and libjvm) used by the Paketo Java sub-team and should be adopted into the Paketo Buildpacks Github Org.

## Motivation

We would like to move the Oracle JDK Buildpack into the Paketo Buildpacks org so that the community can use it to build Java applications, in particular on Oracle Cloud Infrastructure. This will also give the buildpack maintainer the ability to leverage common Paketo tooling to keep the buildpack dependencies updated and release the buildpack.

## Detailed Explanation

N/A

## Rationale and Alternatives

N/A

## Implementation

The Oracle JDK Buildpack will be moved into the `paketo-buildpacks` Github organization and added to the Java sub-team. Maintainenance for this buildpack will be provided by the Java subteam.

The following changes will be made:

- [Oracle JDK Buildpack](https://github.com/eddumelendez/oracle-jdk) moved to Paketo Buildpacks org
- Buildpack will have `paketo-buildpacks/oracle-jdk` ID
- Buildpack will be published to `gcr.io/paketo-buildpacks/oracle-jdk`
- Buildpack will have go module of `github.com/paketo-buildpacks/oracle-jdk`
- An action will be added to [pipeline-builder](https://github.com/paketo-buildpacks/pipeline-builder/tree/main/actions) with the purpose of checking for new versions of Oracle JDK

## Prior Art

[Microsoft OpenJDK Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0001-microsoft-jdk.md)
[Alibaba Dragonwell Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0002-alibaba-jdk.md)

## Unresolved Questions and Bikeshedding

N/A
