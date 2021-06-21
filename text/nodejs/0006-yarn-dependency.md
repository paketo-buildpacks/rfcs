# Providing a Yarn Dependency

## Proposal

In order to enable other buildpacks to execute commands using the `yarn` CLI,
this buildpack will make the `yarn` executable available on the `$PATH`.

## Motivation

[`Yarn`](https://yarnpkg.com/) is a popular and common package manager for
Javascript dependencies. Many Javascript developers will want to execute `yarn`
commands as part of their `build` or `launch` process. Even more directly,
there are already existing
[buildpacks](https://github.com/paketo-buildpacks/yarn-install) that will want
to execute `yarn` commands as part of their `build` process.

In an effort to maintain modularity and simplicity, this buildpack will only
install the executable and leave all other aspects of using `yarn` to other
buildpacks.

## Implementation

### Detect Phase

During detection, the buildpack will provide a `yarn` dependency in its
buildplan. This will enable other buildpacks to require `yarn` be made
available in the `build` and `launch` phases.

Requiring the `yarn` dependency can be accomplished by writing a buildplan
during the detect phase that includes the following requirement:

```toml
[[requires]]
  name = "yarn"
```

### Build Phase

Given that `yarn` is required as part of the buildplan, the buildpack will
create a layer and install the `yarn` executable into that layer, making it
available to subsequent buildpacks or the launcher on the `$PATH` as part of
the [Buildpack
API](https://github.com/buildpacks/spec/blob/main/buildpack.md#layer-paths).

### Specifying dependency inclusion during lifecycle phases

The buildpack will provide an API that allows other buildpacks to signal what
phases the `yarn` executable should be made available in. This is accomplished
by including extra metadata when requiring the `yarn` dependency in the detect
phase. For example, to require that the `yarn` dependency be made available
during both `build` and `launch`, specify a buildplan that looks like the
following:

```toml
[[requires]]
  name = "yarn"

  [requires.metadata]
    build = true
    launch = true
```

This will ensure that the layer that includes the `yarn` executable will be
made available to subsequent buildpacks during the `build` phase. It also
ensures that the layer will ultimately be included as part of the built
application image, and thus available during the application `launch` phase.
