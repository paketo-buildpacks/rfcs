# Support for Yarn "Berry" 

## Summary

The Paketo Node.js Buildpack supports building apps which use
[Yarn](https://yarnpkg.com/) as a package/project management tool. Over the
last few years, the developers of Yarn have released new major versions (v2 &
v3), collectively called Yarn "Berry", which represent a completely new
direction for managing dependencies in Node.js projects. Chief among the
changes is the introduction of [Plug 'n
Play](https://yarnpkg.com/features/pnp), a system which removes the reliance on
`node_modules` and can eliminate the need to run `yarn install` at all. The
Yarn implementation buildpacks do not currently support building apps which use
Berry.  

There have been quite a number of changes in the behaviour of Yarn with the
advent of Berry. Along with performance improvements and optimizations, many
CLI operations and methods of configuration have been deprecated or removed,
including those crucial to the functioning of the buildpack as it exists today. 

## Proposal

Yarn Berry seems to represent the direction in which the project is headed, as
[stated by its lead
maintainer](https://dev.to/arcanis/introducing-yarn-2-4eh1#conclusion). Given
this, and the extent of the changes to the CLI, this RFC proposes that a `yarn-berry-install`
buildpack be created to enable the new installation workflows.

## Motivation

As developers continue to adopt Yarn Berry, demand for the Node.js buildpack to
support it has steadily increased.


## Implementation


### API

`yarn-berry-install`

Provides: `yarn_packages` OR `node_modules` Requires: `node`, during `build`

The buildpack does not require `yarn` since the Berry release itself is meant
to be checked into version control under `.yarn/releases`. Node v16.10 and
later include
[Corepack](https://nodejs.org/dist/latest/docs/api/corepack.html), which is the
preferred method of managing package manager installations across projects. 


A new order group will be added to the Nodejs language family buildpack,
resulting in the following:

```toml
...

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/yarn-berry-install"

  [[order.group]]
    id = "paketo-buildpacks/node-module-bom"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-start"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/yarn-start"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/yarn-install"

  [[order.group]]
    id = "paketo-buildpacks/node-module-bom"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-start"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/yarn-start"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

...

```

The `yarn-berry-install` group is placed before the traditional `yarn-install`
group since it detects on the presence of `.yarnrc.yml` and both app types
will contain `yarn.lock` files.

### Detection

- `.yarnrc.yml` was created with the intention of making it easy to detect
  whether a project uses Yarn Classic or Berry (Berry ignores `.yarnrc`
  completely), and should be used for the detection of `yarn-berry-install`.

### Build

Yarn Berry includes a number of features which seek to remove the necessity of
`yarn install`. As such, the buildpack should allow users to take advantage of
these features by avoiding invocations of `yarn install` when it is reasonable
to do so. For those who opt out of "Plug 'n Play", Berry still supports using
`node_modules`.

The buildpack should run `yarn install` in the following cases:

- If an application uses `node_modules`, which may be determined by the
  presence of a `node_modules` directory or through `.yarnrc.yml` configuration.

- If there is no `.yarn/cache` in the working directory.

- If the `yarn.lock` has changed.

The buildpack should NOT run `yarn install` when:

- Both a `.pnp.cjs` file and `.yarn/cache` are present in the working directory.


The buildpack will store the Yarn cache in a layer and configure Yarn to
reference this layer, ideally via the `YARN_CACHE_FOLDER` environment variable.
For Berry projects using `node_modules`, the behaviour will largely mimic the
existing Yarn Install buildpack, with accommodations for the CLI changes.

### Layer Reuse 

The Yarn Install buildpack currently uses a checksum of the output from `yarn
config list` and the contents of `yarn.lock` to decide whether to reuse cached layers.
`yarn config list` has been removed in Berry, but the new `yarn info` command, which
provides information about the project's direct and transitive dependencies,
should work well as a replacement.

### `--frozen-lockfile`

The existing Yarn Install buildpack passes the `--frozen-lockfile` argument to
every `yarn install` call, which will not update the `yarn.lock` file, and will
fail if the `yarn.lock` file needs to be updated. As such, developers must run
`yarn install` locally in order to update their app's `yarn.lock` file.
`--frozen-lockfile` has been deprecated in favour of `--immutable`, which this
buildpack will utilize.


### Offline builds

Previously, the `yarn-install` buildpack relied on `yarn-offline-mirror` along
with the `--offline` flag to facilitate offline builds. This workflow is no
longer supported and is indeed unnecessary since `.yarn/cache` stores archives
of all packages now anyway.

### Running Scripts

Berry has [changed the way pre- & post- scripts are
invoked](https://yarnpkg.com/getting-started/migration#explicitly-call-the-pre-and-post-scripts).

The build logic of `yarn-start` will need to be modified to accommodate this
change.

### `yarn node` vs `node` 

All `node` commands run via the shell should be run with `yarn node` instead. The default
start command in the Yarn Start buildpack may need to be modified.

## Rationale and Alternatives

- Include logic for Yarn Berry workflows in the existing `yarn-install`
  buildpack. 

  Berry includes breaking changes to the `yarn` CLI used by the buildpack to
  install dependencies. The changes to CLI options are such that at the very
  least, the buildpack would need to decide which ones to use based on the type
  of application being built. Trying to incorporate both workflows will
  increase the scope of responsibility of the buildpack, likely increasing its
  complexity at the expense of maintainability. Classic Yarn is now in
  maintenance mode and, though it is still heavily used now (due to the
  relatively slow adoption of Berry), its unclear how long it will be
  supported. For this reason, it is even more prudent to keep the logic
  separate to facilitate the eventual transition.

- Do nothing.

## Unresolved Questions and Bikeshedding

- Should the buildpack support building Yarn Berry applications which use
  `node_modules` as well as Plug 'n' Play?

- Yarn Berry supports setting a global cache. Should we hold off on supporting
  this workflow until it is requested?
