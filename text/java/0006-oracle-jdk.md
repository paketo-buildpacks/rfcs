# Paketo Buildpacks Oracle Buildpack

## Summary

A [Oracle Buildpack](https://github.com/eddumelendez/oracle) for supplying Oracle's distribution of OpenJDK has been created by [@eddumelendez][@eddumelendez]. It is built using common tooling (libpak and libjvm) used by the Paketo Java sub-team and should be adopted into the Paketo Buildpacks Github Org.

## Motivation

We would like to move the Oracle Buildpack into the Paketo Buildpacks org so that the community can use it to build Java applications, in particular on Oracle Cloud Infrastructure. This will also give the buildpack maintainer the ability to leverage common Paketo tooling to keep the buildpack dependencies updated and release the buildpack.

## Detailed Explanation

Oracle now has binary releases available under the [Oracle No-Fee Terms and Conditions License](https://java.com/freeuselicense). This is a different license than most of the other OpenJDK distributions available through buildpacks (the others utilize GPLv2 + classpath exception).

This Oracle No-Fee Terms and Conditions license, in a nutshell, stipulates that it is OK to redistribute the binaries so long as these two conditions are met.

1. Do not modify the binaries that get redistributed with the buildpacks
2. Do not charge money for the binaries that get redistributed or for any software that redistributes them.

No one writing or reviewing this RFC is a lawyer or qualified to provide legal advice, but it is believed that the buildpack to be contributed complies with these stipulations.

Please be aware if you are consuming Paketo buildpacks and integrating them with other projects (commercial or OSS) & consult your own lawyer if needed.

## Rationale and Alternatives

N/A

## Implementation

The Oracle Buildpack will be moved into the `paketo-buildpacks` Github organization and added to the Java sub-team. Maintainenance for this buildpack will be provided by the Java subteam.

The following changes will be made:

- [Oracle Buildpack](https://github.com/eddumelendez/oracle) moved to Paketo Buildpacks org
- Buildpack will have `paketo-buildpacks/oracle` ID
- Buildpack will be published to `gcr.io/paketo-buildpacks/oracle`
- Buildpack will have go module of `github.com/paketo-buildpacks/oracle`
- An action will be added to [pipeline-builder](https://github.com/paketo-buildpacks/pipeline-builder/tree/main/actions) with the purpose of [checking for new versions of Oracle](https://www.oracle.com/java/technologies/jdk-script-friendly-urls/)

## Prior Art

* [Microsoft OpenJDK Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0001-microsoft-jdk.md)
* [Alibaba Dragonwell Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0002-alibaba-jdk.md)

## Unresolved Questions and Bikeshedding

N/A
