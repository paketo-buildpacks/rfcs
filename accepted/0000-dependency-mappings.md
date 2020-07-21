# Dependency Mappings

## Summary

We should provide a standard mechanism for mapping dependencies to new URIs that works across all Paketo buildpacks.

## Motivation

Consumers of Paketo buildpacks may be building in an environment where certain dependency URIs are inaccessible (due to restrictive firewall rules for example). Operators may want host copies of certain dependencies at different accessible URIs.

## Detailed Explanation

### Discovery
If a mappings file is present at path `<platform>/dependencies/mappings.toml` buildpacks should respect any URIs found the `mappings.toml` file when downloading dependencies.

### Schema
```
[[buildpacks]]
  id = "<buildpack ID>"

  [[buildpacks.mappings]]
   id = "<dependency ID>"
   version = "<dependency version>"
   uri = "<dependency URI>"
```

## Rationale and Alternatives

Alternatively, open source users could package offline versions of the buildpacks. However, this requires knowledge and labor. Additionally, users who only consume a handful of dependencies may not want to pay the cost of downloading very large offline builder images that contain many dependencies that are irrelevant to their use case.

Another alternative would be for buildpacks to expose URI options for each dependency using environment configuration. However this may result in non-standard interfaces or incomplete support for URI mappings.

## Implementation

Before downloading a dependency the buildpack reads the mappings file at the known location, looks up relevant mappings using its own ID. When the buildpack download a dependency it should use provided URI instead of the URI in `buildpack.toml` if a mapping for the dependency exists.

`pack` already allows users to mount arbitrary directories in to the platform dir. Other platforms are likely to follow suite. 

## Prior Art


## Unresolved Questions and Bikeshedding

Would this be better as a binding with kind `dependencies` rather than a custom platform integration?