# Git Buildpack Promotion

## Summary

A [Git Buildpack](https://github.com/paketo-community/git) exists as a
community created buildpack in the [Paketo Community
Org](https://github.com/paketo-community/git). This RFC proposes the promotion
of the Git Buildpack from a "Community" buildpack to an official Paketo
Buildpack.

## Motivation

The community Git Buildpack has reached an initial feature completion state and
supports the ability to configure git authentication credentials. The ability
to configure credentials allows language tools that install modules using `git`
(such as `npm` or `go get`) to install private modules that are in repos that
require credentials to access.

## Implementation

The following changes will be made:

- [Git Buildpack](https://github.com/paketo-community/git) moved from the
  `paketo-community` to `paketo-buildpacks`and become a part of the Utility
  sub-team.
- Buildpack will have `paketo-buildpacks/git` ID.
- Buildpack will be published to `paketobuildpacks/git`.
- Versioning of the buildpack will continue as is.
- Sample apps for common Git buildpacks configurations should be added to the
  [Paketo samples repo](https://github.com/paketo-buildpacks/samples)
- Git buildpack docs should be added to the repos README.
