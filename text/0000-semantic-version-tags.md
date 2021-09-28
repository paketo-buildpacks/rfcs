# Semantic Versioning in Tags for Buildpacks

## Summary

To allow users to use the semantic versioning of buildpacks (see [rfc 0029](./0029-semantic-versioning.md)) in a convenient way, a buildpacks must have tags not only in the format `MAJOR.MINOR.PATCH`, but also `MAJOR.MINOR` and `MAJOR`.

NOTE: Backporting security or bug fixes to older releases is not addressed by this RFC.

## Motivation

Semantic versioning for buildpacks was introduced with [rfc 0029](./0029-semantic-versioning.md), but the buildpacks have only a tag for the complete version (`MAJOR.MINOR.PATCH`). So any user can either use this tag and get no updates at all or the user omits the tag and receives all updates including breaking changes automatically.

With the use of the semantic versioning, it would be good to allow the user to specify which updates should be taken automatically.

## Detailed Explanation

### Major Version Update

When a major version is updated `1.2.3` -> `2.0.0`:

* Tag `2` should address the version `2.0.0`
* Tag `2.0` should address the version `2.0.0`
* Tag `2.0.0` should address the version `2.0.0`
* Tag `latest` should address the version `2.0.0`

This allows users to safeguard from incompatible changes, but still receive new features and security updates.

### Minor Version Update

When a minor version is updated `1.2.3` -> `1.3.0`

* Tag `1` should address the version `1.3.0`
* Tag `1.3` should address the version `1.3.0`
* Tag `1.3.0` should address the version `1.3.0`
* Tag `latest` should address the version `1.3.0` (if v1 is still the latest one)

This allows users to safeguard from incompatible changes and even minor changes, but still receive security updates.

### Patch Version Update

When a patch version is updated `1.2.3` -> `1.2.4`:

* Tag `1` should address the version `1.2.4`
* Tag `1.2` should address the version `1.2.4`
* Tag `1.2.4` should address the version `1.2.4`
* Tag `latest` should address the version `1.2.4` (if v1.2 is still the latest one)

This allows users to pin the version and to be sure that the image is the same.

## Rationale and Alternatives

The only alternative is to keep everything as is. In such case we will miss the points described in the [Motivation](#motivation)

## Implementation

The current workflows that push buildpack images to their registry locations already tag those images with the values `latest` and `MAJOR.MINOR.PATCH`. These workflows should be updated to also include `MAJOR.MINOR` and `MAJOR` tags.

## Prior Art

This is a common pattern and often seen for docker images. A good example is the [Official Python Images](https://hub.docker.com/_/python?tab=tags).

`python` is referring to the overall latest image available.
`python:3` is pinning the major version to 3, but the latest minor and patch versions are used.
`python:3.6` is pinning the major version to 3, the minor version to 6 but the latest patch version is used.
`python:3.6.14` is pinning the exact version.
