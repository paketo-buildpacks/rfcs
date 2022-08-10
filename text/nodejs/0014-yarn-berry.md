# Support for Yarn "Berry" 

## Summary

The Paketo Node.js Buildpack supports building apps which use
[Yarn](https://yarnpkg.com/) as a package/project management tool. Over the
last few years, the developers of Yarn have released new major versions (v2 and
greater), collectively called Yarn "Berry", which represent a completely new
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

* _Throughout this document, Yarn Berry (> 2.x) and Yarn Classic (1.x) will be
  referred to as "Berry" and "Classic" respectively._

## Proposal

Berry seems to represent the direction in which the project is headed, as
[stated by its lead
maintainer](https://dev.to/arcanis/introducing-yarn-2-4eh1#conclusion). Given
this, and the extent of the changes to the CLI, this RFC proposes that Berry
workflows be included in the `yarn-install` buildpack under two separate codepaths/packages.

## Motivation

As developers continue to adopt Berry, demand for the Node.js buildpack to
support it has steadily increased.


## Implementation


### API

`yarn-install`

Provides: `node_modules` OR `yarn_pkgs`
Requires: `node`, `yarn` during `build`

Though the Berry CLI is a complete departure from Classic, the latter may still
be used as a global orchestrator for per-project Berry installations. The
[recommended
workflow](https://yarnpkg.com/getting-started/install#install-corepack) is to
use Corepack (shipped with Node.js) to manage package manager installations,
but this feature is experimental and arguably unnecessary in the context of
buildpack builds where there is only one installation to manage. There are also
challenges with supporting offline use cases using the Corepack workflow (see
Rationale & Alternatives). For now, the buildpack should require `yarn` to
preserve existing functionality & reduce initial engineering cost.

### Detection

The buildpack will pass detection when either of the following criteria is met:

1. A `.yarnrc.yml` is present in the working directory. If present, the
   buildpack should parse the `.yarnrc.yml` and, depending on the value of the
   `nodeLinker` field, should provide either `node_modules` (if `nodeLinker` is
   set to `node-modules` or `pnpm`) or `yarn_pkgs` (if `nodeLinker` is set to
   `pnp` or is absent).

1. `yarnrc.yml` is absent, but `yarn.lock` is present. In this case, `node_modules` should be provided.

### Build

`.yarnrc.yml` was created with the intention of making it easy for tools to
detect whether a project uses Classic or Berry (Berry ignores `.yarnrc`
completely). The buildpack should use this artifact to determine which codepath
to execute.

Berry includes new features which seek to remove the necessity of
actually running `yarn install`. The buildpack should allow users to take advantage of
these features by avoiding invocations of `yarn install` when it is reasonable
to do so. For those who opt out of "Plug 'n Play", Berry still supports using
`node_modules`.

The buildpack should run `yarn install` in the following cases:

- If an application uses `node_modules`, which may be determined by the
  presence of a `node_modules` directory , the absence of `.yarnrc.yml` or
  through explicit `.yarnrc.yml` configuration (via the `nodeLinker` field).

- If the `yarn.lock` has changed when using `node_modules`.

- If there is a `.yarnrc.yml` but no local cache (`.yarn/cache` by default, but may be configured) in
  the working directory, whether `.pnp.cjs` exists or not.

- If there is a `.yarnrc.yml` but no `.pnp.cjs` in the working directory, even if a local cache exists.

The buildpack should NOT run `yarn install` when:

-  `.yarnrc.yml`, `.pnp.cjs` file and a local cache are present in the working
  directory. The buildpack should assume that these artifacts indicate a
  desire to leverage Plug'n'Play and should not need to run `yarn install`
  whether or not the `yarn.lock` has changed between builds.


The buildpack will store the Yarn cache in a layer and configure Yarn to
reference this layer, ideally via the `YARN_CACHE_FOLDER` environment variable.

For Berry projects using `node_modules`, the behaviour will largely mimic the
existing Yarn Install buildpack, with accommodations for the CLI changes.

The buildpack will generate a filesystem-based SBoM as `yarn-install` does currently.

### Layer Reuse

The Yarn Install buildpack currently uses a checksum of the output from `yarn
config list` and the contents of `yarn.lock` to decide whether to reuse package layers.
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

We acknowledge that immutable installs [aren't always
desirable](https://github.com/paketo-buildpacks/rfcs/pull/194#discussion_r893748926).
The buildpack should therefore respect any user-set configuration for disabling
immutable installs.

### Offline builds

Previously, the `yarn-install` buildpack relied on `yarn-offline-mirror` along
with the `--offline` flag to facilitate offline builds. This workflow is not
supported in Berry since `.yarn/cache` stores archives of all packages now
anyway. Airgapped build functionality will remain intact for Classic apps.


### Running Scripts

Berry has [changed the way pre- & post- scripts are
invoked](https://yarnpkg.com/getting-started/migration#explicitly-call-the-pre-and-post-scripts).
The Berry docs recommend that users call their pre- and post-start
scripts explicitly:

E.g.
```
{
  "scripts": {
    "prestart": "do-something",
    "start": "yarn prestart && http-server"
  }
}
```

This could clash with the buildpacks start command logic if users actually
adhere to it and attempting to recreate yarn's logic through the buildpack does
not seem ideal. Instead, we should document this potential conflict and
recommend that users modify their scripts to conform to the previous format:

E.g.
```
{
  "scripts": {
    "prestart": "do-something",
    "start": "http-server"
  }
}
```

This way, the start command logic in `yarn-start` can remain largely unchanged, except
to prepend `yarn` where necessary (see below).

### `yarn node` vs `node`

All `node` commands run via the shell should be run with [`yarn node`
instead](https://yarnpkg.com/getting-started/migration#call-your-scripts-through-yarn-node-rather-than-node).
The default start command in the Yarn Start buildpack will need to be modified
to accommodate this.

## Rationale and Alternatives

- Use Corepack to install Yarn

Corepack is shipped with Node (< 16.10, 14.19) and is the recommended tool for
managing package manager installations across projects. It would be ideal to
conform to the recommended workflow through Corepack, but doing so adds a bit
of complexity for offline builds. Corepack  attempts to download Yarn releases
directly from the registry, which it cannot do in an offline environment. There
are [workarounds](https://nodejs.org/api/corepack.html#offline-workflow) for
this, but they rely on a global [corepack
cache](https://github.com/nodejs/corepack#corepack-prepare--nameversion) which
would have to be replicated within the build/run container. The user would also
have to provide an archive containing the necessary `yarn` release which could
then be "hydrated" by corepack.

- Create an entirely new `yarn-berry-install` buildpack

Given the breadth of the changes to the `yarn` CLI, it is not unreasonable to
consider an entirely separate buildpack for Berry workflows. This approach,
though potentially easier to understand and maintain at the buildpack level,
adds more overhead at the language-family level.


## Unresolved Questions and Bikeshedding

- Offline builds for non-PnP apps

  It is unclear how the buildpack might support offline builds for apps which
  do not utilize PnP, or do not have a local cache at build-time since Berry does
  not respect offline mirrors and does not include a `--offline` flag. The
  `enableGlobalCache` option provides an avenue for running `yarn install` in
  airgapped environments but there is no way to configure the location of the
  global cache or to pre-populate it so that it may be provided at build-time.

 Users would either need to use PnP and utilize the local cache or use Yarn
 Classic to build and run their applications in an airgapped environment.


