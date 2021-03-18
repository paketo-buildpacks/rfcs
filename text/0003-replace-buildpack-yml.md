# Replace buildpack.yml with Build Plan (TOML)

## Summary

`buildpack.yml` is a Paketo specific construct that requires increased overhead for buildpack authors. Everything that is done in `buildpack.yml` can be done with the [`build-plan` buildpack](https://github.com/ForestEckhardt/build-plan), which would offload some logic onto the lifecycle.

## Motivation

With this change we can completely eliminate `buildpack.yml` which is a file that adds undue complexity to the buildpacks because in order for `buildpack.yml` influence what appears in the application image it must be parsed during detection in every buildpack. `buildpack.yml` also has a non-standard format meaning that every single buildpack needs to have slightly unique parsing logic in order to grab a buildpack specific key name and then any other additional metadata.

The big advantage of moving to using `build-plan` is that every buildpack that currently has a `buildpack.yml` parser could remove that code entirely and switch to using Buildpack Plan metadata during the `build` phase and there would be no loss of functionality. The job of parsing build configuration will be condensed into the `build-plan` and then all subsequent parsing will be handled by the buildpack library or the lifecycle.

The format used in `build-plan` is also more powerful than `buildpack.yml` because it allows for fine grain controls as to when that dependency is available by setting `build` and `launch` flags. Any other data that is not the dependency name or version can be put in the metadata section of requires and handled during the `build` phase.

By using the `build-plan` buildpack we can completely replace the `buildpack.yml` while losing no functionality, increase user configurability with very low overhead cost for buildpack authors, and vastly increased interoperability.

## Implementation

The `build-plan` buildpack would need to be added to the end of every build order. If you would like a specific dependency then you can specify that is a `plan.toml`, which is the `requires` portion of a Build Plan (TOML).

In order to facilitate the use of the `build-plan` buildpack it should be migrated from its current location into the `paketo-community` organization. This will allow it to be more easily integrated into the Paketo ecosystem as a whole.

An example of what the conversion from `buildpack.yml` to `plan.toml` would look like the following:

`buildpack.yml`
```yaml
nodejs:
  engine:
    version: ~10
    optimize-memory: true
```

`plan.toml`
```toml
[[requires]]
name = "node-engine"
version = "~10"

[requires.metadata]
    optimize-memory = true
```

The generic layout of `plan.toml` is the following:
```toml
[[requires]]
name = "<dependency name>"
version = "<dependency version>"

[requires.metadata]
# buildpack-specific data

[[or]]

[[or.requires]]
name = "<dependency name>"
version = "<dependency version>"

[or.requires.metadata]
# buildpack-specific data
```

## Unresolved Questions and Bikeshedding

- Can we fold `plan.toml` into another configuration file (like `project.toml`)?
- Are there things we can do/change to make the interface easier for users to understand?

## Additional Information and Consideration

In order for configuration information to be passed to a buildpack by the `build-plan` buildpack, that buildpack must be making some provision. There are two approaches to this problem, either we classify any buildpack that has configuration as making a provision or we find a way to make configuration happen in buildpacks where a provision doesn't make sense (allowing configuration to be set by environment variables or some other alternative).

## Potential Long-Term Goals

The ideal end state for this track or work would be to bake this functionality directly into the lifecycle because of how closely the `build-plan` buildpack already interacts with the lifecycle. The `build-plan` buildpack is a middle ground to test out whether or not this model is a good thing for users and buildpack authors. Once this model has proven (or disproven) itself, learnings from this stop gap should be used to inform further actions (whether that be pursuing integration in the lifecycle or abandoning this model for something else).

{{THIS SECTION SHOULD BE REMOVED BEFORE RATIFICATION}}
