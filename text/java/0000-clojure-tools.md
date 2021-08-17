# Clojure Tools Buildpack

## Summary

A Clojure Tools buildpack for building Clojure applications using [deps][d] and [tools build][t] has been created [by the community][b].  It is based on the same technologies and is nearly indistinguishable from the other Paketo Buildpacks, especially the JVM build-system buildpacks, and it should be adopted into the project.

[d]: https://clojure.org/guides/deps_and_cli
[t]: https://clojure.org/guides/tools_build
[b]: https://github.com/eddumelendez/clojure

## Motivation

This is an additional buildpack, for building JVM-based applications based on Clojure, and offers yet another workload that can be built by Paketo buildpacks.

## Detailed Explanation

The Clojure Tools Buildpack will be moved into the paketo-buildpacks Github organization and added to the Java sub-team. Maintenance for this buildpack will be provided by the Java subteam.

The following changes will be made:

* [Clojure Tools Buildpack][b] moved to Paketo Buildpacks org
* Buildpack will have paketo-buildpacks/clojure ID
* Buildpack will be published to gcr.io/paketo-buildpacks/clojure
* Buildpack will have go module of github.com/paketo-buildpacks/clojure
* Github Actions will be added through [pipeline-builder][p]
* An action will be added to [pipeline-builder][p] with the purpose of checking for new versions of Clojure Tools

[b]: https://github.com/eddumelendez/clojure
[p]: https://github.com/paketo-buildpacks/pipeline-builder

## Rationale and Alternatives

N/A

## Implementation

This buildpack will be adopted by the Java Buildpacks team and transferred to the `paketo` GitHub organization.  The original author will be added as a contributor to the Java subteam.

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

N/A
