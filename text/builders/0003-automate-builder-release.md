# Automated Builder Releases

## Summary

This RFC proposes that the builder repos should automatically cut new releases
(and publish the corresponding builders) whenever the `builder.toml` on the
`main` branch changes.

## Motivation

Many Paketo users build app images using builders without specifying buildpacks
separately. In order for these users to consistently build with the latest
versions of Paketo buildpacks, builder versions must be released promptly after
new buildpack versions are available. The current manual builder release
process is a bottleneck.

## Detailed Explanation

The proposed approach is to cut releases of builders when there are commits to
the `main` branch that change the `builder.toml`. The existing builder
automation specified in [RFC 0002](https://github.com/paketo-buildpacks/builder/blob/main/rfcs/0002-buildpack-toml-versioning.md)
handles updating of the `builder.toml` upon the release of new buildpack
versions. With the proposed change, a builder will be
automatically released when new buildpacks (or buildpack versions) are added to
the builder. Checking whether the `builder.toml` has changed before cutting a
release also avoids the case where a builder is released simply because of a
cosmetic change to its repo (e.g. change to the README).

## Rationale and Alternatives

### Alternative 1: Do nothing
Without this change, releases of builders will have to be cut manually. This
has the benefit of allowing maintainers to be more judicious about when to
release builders. The drawback is that builder release relies on manual work
and can easily be forgotten. It also requires Builders maintainers to have
context on the buildpacks in builders in order to understand when it makes
sense to cut a release.

### Alternative 2: Cut a release on push to `main`

We can further automate the repo by cutting a release on any change to the
`main` branch. This would be very simple to implement (basically a one-line
change from the current automation). However, it could result in builders with
different version numbers being functionally identical. This is perhaps
confusing to users.

## Implementation

The RFC requires two changes to the current `create-draft-release.yml` workflow:
1. Add a check to see whether the `builder.toml` differs from the latest release.
1. Publish a non-draft release if tests pass and the `builder.toml` has changed.

## Prior Art

[RFC 0002](https://github.com/paketo-buildpacks/builder/blob/main/rfcs/0002-buildpack-toml-versioning.md)
indicates that builders should be released "with a new version whenever the
maintainer wants."

Currently, Paketo implementation and language-family buildpacks are released manually by subteam maintainers.

Previously, builders were released via [a concourse
pipeline](https://buildpacks.ci.cf-app.com/teams/core-deps/pipelines/cnb-builder)
that watched for changes to CNBs, build images, and lifecycle versions.

## Unresolved Questions and Bikeshedding

{{Write about any arbitrary decisions that need to be made (syntax, colors, formatting, minor UX decisions), and any questions for the proposal that have not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
