# Replace buildpack.yml with Build Plan (TOML)

## Summary

`buildpack.yml` is a Paketo specific construct that requires increased overhead for buildpack authors. Everything that is done in `buildpack.yml` can be done with the [`build-plan` buildpack](https://github.com/ForestEckhardt/build-plan), which would offload some logic onto the lifecycle.

## Motivation

With this change we can completely eliminate `buildpack.yml` which is a file that adds undue complexity to the buildpacks which could be offloaded entirely to the lifecycle.

## Implementation

The `build-plan` buildpack would need to be added to the end of every build order. If you would like a specific dependency then you can specify that is a `plan.toml`, which is the `requires` portion of a Build Plan (TOML). This format is more powerful than `buildpack.yml` because it allows for fine grain controls as to when that dependency is available by setting `build` and `launch` flags. Any other data that is not the dependency name or version can be put in the metadata section of requires and handled during the `build` phase. By using the `build-plan` buildpack we can completely replace the `buildpack.yml` while losing no functionality, increase user configurability with very low overhead cost for buildpack authors, and vastly increase interoperability.

## Unresolved Questions and Bikeshedding

- Can we fold `plan.toml` into another configuration file (like `project.toml`)?
- Are there things we can do/change to make the interface easier for users to understand?

{{THIS SECTION SHOULD BE REMOVED BEFORE RATIFICATION}}

