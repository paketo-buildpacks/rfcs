# Build Flags

## Proposal

The Go
[documentation](https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies)
of the `go build` command outlines a number of "build flags" that command users
might set. Out of that list, the current implementation of the buildpack sets
the `-buildmode` and `-mod` flags to default values. Application developers
should be able to override these values and have the ability to set new values that
are not part of the defaults.

### Existing support
The
[go-mod](https://github.com/paketo-buildpacks/go-mod#buildpackyml-configuration)
and [dep](https://github.com/paketo-buildpacks/dep/#buildpackyml-configuration)
buildpacks already have configurable settings for including `-ldflags`. An
example of that functionality can be seen below.

```yaml
---
go:
  ldflags:
    main.version: v1.2.3
    main.sha: 7a82056
```

### Proposed `buildpack.yml` format
In order to accomodate the option to set a number of flags without needing to
implement a separate field in the `buildpack.yml` for each of those flags, we
propose that the `buildpack.yml` API be widened to accept a generic list of
"build flags". In this form, the above example would look like the following:

```yaml
---
go:
  build:
    flags:
    - -ldflags='-X main.version=v1.2.3 -X main.sha=7a82056'
```

The more generic API allows us to support all of the build flags provided by
the `go build` command without needing to widen the API contract any further.
For example, to include build tagging and race detection during `go build`,
application developers could specify something like the following:

```yaml
---
go:
  build:
    flags:
    - -ldflags='-X main.version=v1.2.3 -X main.sha=7a82056'
    - -tags=paketo,production
    - -race
```

### Breaking change
Since the `buildpack.yml` API would change from its existing form, this is
considered to be a breaking change and would impact buildpack users that are
using this feature. The existing functionality would still be implemented, but
through a more generic API.

### Overriding defaults
In addition to setting new flags, this API change will allow buildpack users to
override those default values. For example, when a buildpack user includes
`-buildmode=exe` in their list of build flags, it will override the default
setting of `-buildmode=pie` for the invocation of the `go build` compilation
process.

Allowing buildpack users to override these default values is a useful feature,
but we will need to make sure that those users understand the ramifications of
their choice. This can simply be documentation that describes how the buildpack
functions.

## Motivation

Changing the API for setting build flags will enable more configuration for
buildpack users while simplifying the work required for buildpack developers.

There are already existing users of the current LDFlags feature as well as
[open issues](https://github.com/paketo-buildpacks/go-mod/issues/14) requesting
that we support a larger number of flags.

## Addendum: preview of future build plan configuration

At a future date, this buildpack will implement the [Build Plan
RFC](https://github.com/paketo-buildpacks/rfcs/blob/master/accepted/0003-replace-buildpack-yml.md)
and remove support for `buildpack.yml`. In that case, the configuration above
would change to look something like this:

```toml
[[requires]]
name = "go-targets"

[requires.metadata]
  flags = [
    "-ldflags='-X main.version=v1.2.3 -X main.sha=7a82056'",
    "-tags=paketo,production",
    "-race"
  ]
```

At that point, the buildpack would "provide" `go-targets` as part of its build
plan so that other buildpacks, or buildpack users could require it. Other than
this new provision, the remainder of the configuration is a rather direct
translation from YAML to TOML.
