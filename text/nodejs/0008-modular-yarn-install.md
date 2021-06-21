#  Yarn Install Buildpack Modularization

## Proposal

As part of the re-architecture of the Node.js metabuildpack outlined
[here](https://github.com/paketo-buildpacks/nodejs/blob/main/rfcs/0001-buildpacks-architecture.md),
the `yarn-install` buildpack should be changed to have the single responsibility of running  the `yarn install`
command, which will install dependencies to `node_modules`.

Currently, the `yarn-install` buildpack is responsible for providing yarn on
PATH, installing dependencies in the local node_modules folder, and sets a
start command. With the work outlined in the re-architecture RFC linked above,
the [`yarn` buildpack](https://github.com/paketo-buildpacks/yarn) and
[`yarn-start` buildpack](https://github.com/paketo-buildpacks/yarn-start) have
been created, and take care of providing yarn on PATH, and setting a start
command, respectively. The last chunk of work in this group is to remove the
extra functionality from `yarn-install`, so that each buildpack in the order
grouping has a single, modular functionality.

## Motivation

Moving toward this single-responsibility architecture has a few advantages:

* It enables greater modularity within the Node.js language family.

* It sets the foundation for interoperability between buildpacks across
  language families.

* It provides clarity since the buildpacks are aptly named for their functionality.

## Integration

The buildpack will provide `node_modules` and will require `node` and
`yarn` during the build phase.

## Implementation (Optional)

Detection will pass once there is both a `yarn.lock` and `package.json` file is present in the app's source
code, assuming all other buildplan requirements have been met.

If detection is passed, the buildpack will provide `node_modules` as a
dependency. After the first build, the the sha256 of the `yarn.lock` file is
cached, and yarn install will only run if the `yarn.lock` file has changed.

The buildpack passes the `--frozen-lockfile` argument to every `yarn install` call,
which will not update the `yarn.lock` file, and will fail if the `yarn.lock` file
needs to be updated. So, developers must run `yarn install` locally in order to update
their app's `yarn.lock` file.

To use the buildpack in an offline environment
the application must include an [`offline-mirror`](https://classic.yarnpkg.com/blog/2016/11/24/offline-mirror/) and [`.yarnrc`](https://classic.yarnpkg.com/en/docs/yarnrc/) file. The `yarn
install` command will be run with the `--offline` flag if the offline mirror
directory is present. The `offline-mirror` directory must be discoverable with the
`yarn config get yarn-offline-mirror` command.
