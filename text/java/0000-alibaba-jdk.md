# Paketo Buildpacks Alibaba Dragonwell Buildpack

## Summary

A [Alibaba Dragonwell Buildpack](https://github.com/eddumelendez/dragonwell) for supplying Alibaba's distribution of OpenJDK has been created by [@eddumelendez][@eddumelendez]. It is built using common tooling (libpak and lijvm) used by the Paketo Java sub-team and should be adopted into the Paketo Buildpacks Github Org.

## Motivation

We would like to move the Alibaba Dragonwell Buildpack into Paketo Buildpacks so that the community can use it to build Java applications, in particular on Alibaba Cloud. This will also give the buildpack maintainer the ability to leverage common Paketo tooling to keep the buildpack dependencies updated and release the buildpack.

## Detailed Explanation

N/A

## Rationale and Alternatives

N/A

## Implementation

The Alibaba Dragonwell Buildpack will be moved into the `paketo-buildpacks` Github organization and added to the Java sub-team. Maintainenance for this buildpack will be provided by the Java subteam.

The following changes will be made:

- [Alibaba Dragonwell Buildpack](https://github.com/eddumelendez/dragonwell) moved to Paketo Buildpacks org
- Buildpack will have `paketo-buildpacks/alibaba-dragonwell` ID
- Buildpack will be published to `gcr.io/paketo-buildpacks/alibaba-dragonwell`
- Buildpack will have go module of `github.com/paketo-buildpacks/alibaba-dragonwell`
- Github Actions will be added through [pipeline-builder](https://github.com/paketo-buildpacks/pipeline-builder)
- An action will be added to [pipeline-builder](https://github.com/paketo-buildpacks/pipeline-builder/tree/main/actions) with the purpose of checking for new versions of Alibaba's Dragonwell OpenJDK

## Prior Art

[Leiningen Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/master/accepted/0004-clojure.md)
[Rust Buildpack](https://github.com/paketo-buildpacks/rfcs/blob/master/accepted/0014-rust.md)

## Unresolved Questions and Bikeshedding

N/A
