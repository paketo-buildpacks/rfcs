# Deprecate the `dep` and `dep-ensure` Buildpacks

## Proposal

The `dep` and `dep-ensure` Buildpacks should be deprecated.

## Motivation

`dep` was a package management tool created for Go before the introduction of
`go mod`. Since the introduction of `go mod` the `dep` tool has since been
deprecated and archived by the team working on it (See the [Github
Repository](https://github.com/golang/dep) and the [`dep`
documentation](https://golang.github.io/dep/docs/introduction.html)). Because
this tool has been deprecated and `go mod` has been widely adopted by the Go
community, we should deprecate our buildpacks.

## Implementation

To deprecate the `dep` tool we should do the following:
- Archive both the `dep` and `dep-ensure` buildpack repositories
- Remove any and all related order groups from the language family buildpack
- Remove logic in `go-build` designed to accomodate for a use of the `dep` tool
- Remove any samples in the samples repository that use the `dep` tool
- Change the documentation on the website by either removing `dep` specific
  documentation or replace it with an indication that the workflow has been
  deprecated
