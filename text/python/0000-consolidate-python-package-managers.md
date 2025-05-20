# Consolidate Python package managers buildpacks

## Summary

The goal is to centralize the handling of the various existing Python package
managers under two buildpacks. Each handling a specific task:

- Package manager installation
- Package manager usage

## Motivation

This consolidation will allow to reduce the number of buildpacks required to
handle Python projects. From a consumer point of view, this will make no
difference however for maintainers, this will simplify their tasks:

- 2 code bases against 8 currently
- 2 release to manage against 8 currently
- adding a new package manager such a pixi or uv will be simplified

## Detailed Explanation

Currently, each package manager is handled through at least two different
buildpacks:

1. One that installs the manager
2. One that detects if the manager should be used and consequently makes use of
  it

This means that there's currently eight repositories to keep updated with regard
to new manager versions but also for dependencies, security issues, etc.

These new buildpacks would replace eight buildpacks with two at the expense
of a larger code base but with the benefit of pooling efforts in a single
place.

As a side effect, it also makes it easier to add support for new package
managers since they will now be handled centrally.

## Implementation

For the package manager user buildpack, the most simple implementation would be
to pick the code from the original buildpacks together under one roof and do
each detection in sequence as is currently done by the lifecycle.

A similar approach shall be applied to the installer buildpack.

Care should be taken to harmonize the code so as to simplify maintenance as
well.

## Prior Art

Already existing buildpacks:

- paketo-buildpacks/miniconda
- paketo-buildpacks/pip
- paketo-buildpacks/pipenv
- paketo-buildpacks/poetry

- paketo-buildpacks/conda-env-update
- paketo-buildpacks/pip-install
- paketo-buildpacks/pipenv-install
- paketo-buildpacks/poetry-install
