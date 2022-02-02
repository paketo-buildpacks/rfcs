# Source Removal Buildpack

## Summary

Adopt [ForestEckhardt's Source Removal buildpack](https://github.com/ForestEckhardt/source-removal)
into the Paketo Project to allow for uniform source removal logic across all
buildpacks that require such functionality.

## Motivation

There are several buildpacks in the Paketo Buildpacks project that take their
given source code and transform that into a new artifact such as a binary or
other forms of compiled/transpiled code. It is often desirable to remove any
unnecessary source code from the final image as it causes image bloat and poses
a potential security risk. In order to currently accomplish this, any buildpack
that wants to remove source code must have logic to remove it from the
`workspace` so that it does not appear in the final image, however this task is
complicated because often times there are static files that are required for
the app to run that should no be deleted from the `workspace`. This leads to
multiple implementations of non-trivial file removal logic across different
buildpacks.

This could all be simplified by adding a buildpack that performs all source
removal logic to the end of any buildpack order that would require things to be
removed from the `workspace` which is exactly what ForestEckhardt's Source
Removal buildpack does. This buildpacks allows this shared logic to be
centralized into one place and then reused across the entire buildpack
ecosystem and as needed by particular users.

## Rationale and Alternatives

- Continue to implement source removal logic in all buildpacks that would
  benefit from such functionality.

## Implementation

Currently ForestEckhardt's Source Removal buildpack always passes detection and
has four actions.

1. If no configuration is set (i.e. `BP_INCLUDE_FILES` and `BP_EXCLUDE_FILES`
   are not set), then all the content of the `workspace` will be deleted.
2. If `BP_INCLUDE_FILES` is set, then all files that **do not** match the
   pattern globs specified in the environment variables will be deleted.
3. If `BP_EXCLUDE_FILES` is set, then all files that **do** match the pattern
   globs specified in the environment variables will be deleted.
4. If `BP_INCLUDE_FILES` is set and `BP_EXCLUDE_FILES` is set, then firstly all
   files that **do not** match the pattern globs specified in the environment
   variables will be deleted, secondly all files that **do** match the pattern
   globs specified in the environment variables will be deleted in that order.

This buildpack would fall under the Utility Teams maintainership.

## Prior Art

- [Paketo Go Build Buildpack](https://github.com/paketo-buildpacks/go-build/blob/main/source_deleter.go)
- [Google Clear Source](https://github.com/GoogleCloudPlatform/buildpacks/blob/main/pkg/clearsource/clearsource.go)
