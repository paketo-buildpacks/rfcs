# Git Support

## Proposal

Introduce an (optional) Git buildpack into each language buildpack family. The buildpack
will be charged with providing `git` metadata as build-time and run-time environment
variables.

This buildpack would be maintained by the existing Tooling team.
## Motivation

Applications of any language may have a need for information extracted from
`git` metadata. For example, the commit sha might be used as versioning
information when building a Go binary or used when running a Rails application.

## Implementation

A new `git` buildpack will be developed to detect whether the `.git` directory, and then
read the directory to extract the following environment variables so that they
can be included in the built image.

- `REVISION`

### Detection Criteria

The buildpack will detect if the `.git` directory is present.

### Build Process

The build process of the buildpack will find the values for the
expected environment variables and add them to a layer for use at launch.

### Buildpack Order Grouping

The `git` buildpack can be added to each family buildpack or it can be added
separately at the beginning of each ordering defined in a builder.

For example:

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/git"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/go"
    version = "<version>"

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/git"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/ruby"
    version = "<version>"
```
