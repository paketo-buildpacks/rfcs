# Rename open liberty buildpack to liberty

## Summary

The `open-liberty` buildpack can contribute either the Open Liberty or Websphere Liberty runtime.  To avoid confusion the buildpack should simply be named `liberty`.

## Motivation

There are a few motivations for this change:

1. The open-liberty buildpack name is misleading because the buildpack can contribute Open Liberty or WebSphere Liberty.  
2. Avoid confusion on what the buildpack contributes.
3. The buildpack has not been released as 1.0, and is not included in a composite buildpack or builder so a name change now will have minimal impact.  

## Detailed Explanation

[RFC 0031](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0031-liberty-buildpack.md) indicated both Open Liberty and WebSphere Liberty would be available.  The
original `open-liberty` buildpack contributed by the community only contributed `Open Liberty`.  We have since added support for WebSphere Liberty.     


## Rationale and Alternatives

Alternatives:

- Do nothing. Users of the Open Liberty buildpack may not know WebSphere Liberty is available and we will need to repeatedly explains WebSphere Liberty is available.  

## Implementation

1. Cut a release with the current name with any unreleased features in progress.  
2. Make the name change
	2a. Rename the `open-liberty` repo to `liberty`.
	2b. Modify files (buildpack.toml, etc) and directories that reference open liberty.  
3. Cut a new release with the new name.  

## Prior Art

- None

## Unresolved Questions and Bikeshedding

- None