# Dependency Library to Provide Dependency Info

## Summary

The dependency metadata that is provided by the [Dep Server](https://github.com/paketo-buildpacks/dep-server) is backed partially by a Go library which provides information about upstream dependencies (available versions, release dates, source code URLs and SHAs, etc.). This RFC proposes creating a new repo that will expose this underlying resource.

## Motivation

By exposing this library, buildpack authors who use the Dep Server will have access to and insight into more of the underlying resources backing the server.

Exposing this library will also allow authors to make contributions to add additional languages or modify the logic surrounding existing languages.

## Detailed Explanation

The library will contain two public methods that can be called for all upstream dependencies:
  * `GetAllVersionRefs`:
    * Lists all available versions of the dependency
  * `GetDependencyVersion`:
    * Returns information about a specific version (release date, source code URL and SHA, deprecation date (if available))

## Rationale and Alternatives

### Not expose this library
We could choose not to add this library to paketo-buildpacks. Ideally all of the code backing the Dep Server would live in paketo-buildpacks and so choosing not to add this library would make it difficult to reach that goal.

## Implementation

The dependency library will live in a new repo (perhaps `github.com/paketo-buildpacks/dependency`).

The library is written in Go.

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

* How will releasing/versioning of the library be handled? Will we release a new version for each commit that passes some set of tests?
