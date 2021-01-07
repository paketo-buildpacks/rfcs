# Distribute Buildpacks via Docker Hub

## Summary

In addition to the current Google Container Registry (GCR) distribution
channel, buildpacks should be distributed via Docker Hub.

## Motivation

Docker Hub is a commonly expected distribution channel for OSS container
images. We already distribute our builder images on Docker Hub and treat it as
the preferred location for those images in documentation. Distributing builders
via Docker Hub and buildpacks via GCR creates confusion and friction for our
users.

Additionally, moving to Docker Hub would mean that, eventually, we should be
able to deprecate our distribution via GCR.

## Detailed Explanation

We will establish 2 Docker Hub accounts (`paketobuildpacks` and
`paketocommunity`) to house the existing set of buildpack images. Buildpacks
belonging to the `paketo-buildpacks` GitHub organization will be published to
the `paketobuildpacks` account, and buildpacks belonging to the
`paketo-community` GitHub organization will be published to the
`paketocommunity` account. Buildpacks will continue to follow their existing
patterns for image names and versions (e.g. the
`gcr.io/paketo-buildpacks/php:0.0.11` image would be found at
`docker.io/paketobuildpacks/php:0.0.11`). Distribution via Docker Hub will
apply to both "component" and "composite" buildpacks under the Paketo
Buildpacks project.

Buildpacks are not expected to "republish" historic releases to Docker Hub,
only to start publishing all new releases there.

It is expected that buildpacks currently distributed via GCR will continue to
be distributed through GCR until such time as a deprecation notice can be
broadcast and sufficient time is given to facilitate a changeover for
downstream consumers.

Earlier this year, Docker established image retention policies and pull
rate-limits for repositories hosted on Docker Hub. Additionally, Docker has
outlined exception criteria for Open Source community projects, recognizing a
need to support open source developer collaboration and innovation. In order to
ensure that users have unencumbered access to our buildpack images, the Paketo
Buildpacks project should apply for designation as an Open Source Community as
outlined in this Docker [blog
post](https://www.docker.com/blog/expanded-support-for-open-source-software-projects/).

## Rationale and Alternatives

Docker Hub is the largest distribution channel for Open Source container
images. Moving our primary distribution channel to Docker Hub aligns with
existing expectations within the larger OSS community.

If we choose not to adopt the above change, there are a couple of alternatives
that remain.

We could do nothing. This would mean that the existing experience for users to
find builder and buildpack images would remain confusing.

As another option, we could choose to move entirely away from Docker Hub,
choosing GCR as the standard location for distribution of buildpacks and
builders. While this would ultimately result in fewer images needing to be
moved, the choice of distribution channel does not necessarily align with
expectations within the larger OSS community.

## Implementation

After setting up credential information for the Docker Hub account on GitHub,
buildpack repositories will start to publish new releases to their Docker Hub
locations alongside their existing GCR locations until such time as the GCR
locations are deprecated.

## Prior Art

We already publish builders to Docker Hub. We can simply extend that existing
pattern to cover our buildpacks as well.
