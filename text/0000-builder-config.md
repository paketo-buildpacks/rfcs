# Builder Config

## Summary

This RFC proposes an easy way to configure builders to allow specifying a `config.toml` file that allows updating the Buildpack `detect` and `build` environment based on the configuration file.

## Motivation

Often times, especially in enterprise settings, organizations often have to update the buildpacks to use internal mirrors, proxies and other settings which can be configured easily with environment variables.

Some examples include -
- `GOPROXY`
- `PIP_INDEX_URL`
- `npm_config_registry`
- `BUNDLE_MIRROR__URL`

The buildpack logic in `Paketo` largely remains the same, except these environment variables might need to be injected during the `build` and `detect` phases.

The environment variables may be able to take precedence over user-provided values, if configured to, which ensures that operators can take full control over their builders if that is required.

## Detailed Explanation

The RFC proposes the introduction of the following file `/builder/config.toml`.

The `config.toml` has an optional section `build.env`. This section allows defining key/value pairs of environment variables.  Environment variables are defined with optional suffixes.  The following table describes the possible definitions for an environment variable called `KEY`:

```toml
api = "0.1"

[[build.env]]
name = "KEY"
# If value is not specified, it is assumed to be an empty string.
value = "VALUE"
# `default` is the mode that is used if `mode` is undefined
# This means that the environment variable `KEY` will be set to `VALUE`
# if it is not set already.
mode = "default"

[[build.env]]
name = "KEY"
value = "VALUE"
# This means that the environment variable `KEY` will be set to `VALUE`
# regardless of its existing value.
mode = "override"

[[build.env]]
name = "KEY"
value = "VALUE"
# This means that the environment variable `KEY` will have `VALUE`
# prepended to its existing value with a delimiter `:`. If `delim` is not
# specified, a default value of `os.PathListSeparator` is used.
mode = "prepend"
delim = ":"

[[build.env]]
name = "KEY"
value = "VALUE"
# This means that the environment variable `KEY` will have `VALUE`
# appended to its existing value with a delimiter `:`. If `delim` is not
# specified, a default value of `os.PathListSeparator` is used.
mode = "append"
delim = ":"

[[build.env]]
name = "KEY"
# This means that the environment variable `KEY` will have its value unset.
mode = "unset"
```

The proposal is that both `libpak` and `packit` update their `detect` and `build` functions to check for the existence of this file and if it exists, update the `detect` and `build` environment of the buildpack with the appropriate values.

Additionally individual buildpacks using `libpak` and `packit` may choose to customize this functionality via the following keys in their `buildpack.toml` -

```
[metadata]
# Defaults to `false`. If set to `true`, will not source values from the buider config.
disable-builder-config = true
# Defaults to a common /builder/config.toml
builder-config-path = "/builder/mybuildpack/config.toml"
```

This would allow individual buildpacks to source a different set of environment variables or even disable this behavior entirely if they don't want it enabled.

## Rationale and Alternatives

The rationale for introducing it in `libpak` and `packit` as opposed to a separate buildpack that looks for the existence of this file is motivated by the following -

- Allowing environment variables to be set during the `detect` process of a Buildpack.
- Allowing the builder config to have a higher precedence over user provided environment variables via the platform.
- Allow individual buildpacks to have different `builder-config` files.

The alternative i.e. a singular `builder-config` buildpack that is present at the beginning of each buildpack group and sets these variables using the normal buildpack API does not fulfil the requirements around being able to update the detect environment or being able to override platform environment variables or allowing a group of buildpacks to be configured separately than the others.

## Implementation

### Packit

Update the [`packit.Detect`](https://github.com/paketo-buildpacks/packit/blob/8bb254b2ffd187769f9afb5045189767c7c79a35/detect.go#L56) and [`packit.Build`](https://github.com/paketo-buildpacks/packit/blob/8bb254b2ffd187769f9afb5045189767c7c79a35/build.go#L87) method to do the following -

- Check the `buildpack.toml` for the builder config related keys. If present, update the default value.
- If `disable-builder-config` is set to `false`, check for the presence of the file pointed to by `builder-config-path`.
  - If present and valid, continue.
  - If not, skip the builder configuration.
- Source the config file. For each key in `[build.env]` update the environment using `os.Environ` based on the suffix.
- Continue with the normal `build`/`detect` process.

The reference implementation for packit is available at https://github.com/paketo-buildpacks/packit/pull/383

### libpak

Similar to `packit`, `libpak` would need updates at [`libpak.Detect`](https://github.com/paketo-buildpacks/libpak/blob/main/detect.go#L41) and [`libpak.Build`](https://github.com/paketo-buildpacks/libpak/blob/e0f98e15e06c74db97d0f1547a36aa22f4bad9f4/build.go#L41)


## Prior Art

See the CNB BAT meeting. https://youtu.be/e8FgLwVN5VQ?t=1153

## Unresolved Questions and Bikeshedding

Default name of the file.
