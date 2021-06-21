# Refactoring the NPM Buildpack

## Proposal

This RFC aims to outline the changes required to create an `npm-install`
buildpack from the current `npm` buildpack, in alignment with the [Node.js
re-architecture](https://github.com/paketo-buildpacks/nodejs/blob/main/rfcs/0001-buildpacks-architecture.md)
RFC.

## Motivation

As part of the Node.js re-architecture, the group of buildpacks used to build
an app which uses npm has changed. The `node-engine` buildpack provides `node`
and `npm`, and the `npm-start` buildpack bookends the order grouping by setting
the relevant start command with `tini`. Thus, there is a need for a buildpack
which generates and provides a given application's `node_modules`.

## Integration

This buildpack will provide `node_modules` and will require `node` and `npm` at
build time.


## Implementation

The major changes to the existing `npm` buildpack will be as follows:

1. Change the name of the buildpack to `npm-install`.
2. The buildpack will no longer set a start command, that is now the job of
   `npm-start`.
3. The buildpack will no longer require itself, `npm-start` now requires
   `node_modules` to trigger detection for this buildpack.
4. The buildpack will now require `node` and `npm` at build.
