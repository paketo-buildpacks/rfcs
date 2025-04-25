# Consolidate Python package managers buildpacks into one

## Summary

The goal is to centralize the handling of the various existing Python package
managers under one single buildpack.

## Motivation

This consolidation will allow to reduce the number of buildpacks required to
handle Python projects. From a consumer point of view, this will make no
difference however for maintainers, this will simplify their tasks:

- 1 code base against 4 currently
- 1 release to manage against 4 currently
- adding a new package manager such a pixi or uv will be simplified

## Detailed Explanation

Currently, each package manager is handled through at least two different
buildpacks:

1. One that installs the manager
2. One that detects if the manager should be used and consequently makes use of
  it

This means that there's currently eight repositories to keep updated with regard
to new manager versions but also for dependencies, security issues, etc.

This new buildpack would handle the latter for all supported managers effectively
replacing four buildpacks with one at the expense of a larger code base but with
the benefit of pooling efforts in a single place.

As a side effect, it also makes it easier to add support for new package
managers since only one new buildpack needs to be created.

## Implementation

The most simple implementation would be to pick the code from the original
buildpacks together under one roof and do each detection in sequence as is
currently done by the lifecycle.

Care should be taken to harmonize the code so as to simplify maintenance as
well.

## Prior Art

Already existing buildpacks:

- paketo-buildpacks/conda-env-update
- paketo-buildpacks/pip-install
- paketo-buildpacks/pipenv-install
- paketo-buildpacks/poetry-install
