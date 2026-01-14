# Bumping the Default Node.js Version for Paketo Node.js Buildpacks

## Summary

This RFC defines the criteria and formal process for upgrading the default Node.js version across the Paketo Node.js Buildpacks.

## Motivation

We are clarifying what are the requirements before a new Node.js version becomes the default in Paketo Buildpacks.

## Detailed Explanation

The default Node.js version should be changed on the Paketo Node.js Buildpacks if **all** the following criteria are met:

- The Node.js version must be in the `active LTS` status, according to the [Node.js Release Schedule](https://github.com/nodejs/Release)
- The candidate version must be higher than the current default version.
- The candidate version must pass all the integration tests across all the Paketo Node.js Buildpacks.

## Rationale and Alternatives

- Do nothing and don't upgrade the default Node.js version. This solution risks missing performance and security improvements.
- Upgrade default Node.js version without testing it across all the Paketo Node.js buildpacks. This solution risks of breaking downstream builds.

## Implementation

The upgrade process is divided in the following phases.

### 1. Make the candidate version available

Once you have ensured that the candidate version is on `active LTS` status based on the [Node.js release schedule](https://github.com/nodejs/Release).

**For Ubuntu Builders**:

- Add the candidate version on the `buildpack.toml` as on this [PR](https://github.com/paketo-buildpacks/node-engine/pull/1356)

- Bump the `node-engine` buildpack semver version to `minor`, based on the [Semantic Versioning RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0029-semantic-versioning.md)
- Publish a release.

**For UBI builders**:

- Add the base images that have the candidate version on the `ubi-x-base-images` repositories, as on [this PR](https://github.com/paketo-buildpacks/ubi-9-base-images/pull/21)
- Patch the [ubi-nodejs-extension](https://github.com/paketo-buildpacks/ubi-nodejs-extension) to support the new version as on [this PR](https://github.com/paketo-buildpacks/ubi-nodejs-extension/pull/444) and publish a release.

### 2. Test the candidate version across all Paketo Node.js Buildpacks

In order to ensure that the candidate version works with all the Paketo Node.js Buildpacks, add on their integration tests the candidate version, on the following repositories as of today (January 2026):

| Repository                                | Action Required                            | Example PR                                                           |
| :---------------------------------------- | :----------------------------------------- | :------------------------------------------------------------------- |
| `npm-install`                             | Replace version in tests; publish release. | [PR #934](https://github.com/paketo-buildpacks/npm-install/pull/934) |
| `node-start`                              | Replace version in tests; publish release. | [PR #717](https://github.com/paketo-buildpacks/node-start/pull/717)  |
| `yarn-start`                              | Replace version in tests; publish release. | [PR #698](https://github.com/paketo-buildpacks/yarn-start/pull/698)  |
| `npm-start`                               | Replace version in tests; publish release. | [PR #790](https://github.com/paketo-buildpacks/npm-start/pull/790)   |
| `yarn`, `yarn-install`, `node-run-script` | No version-specific test updates required. | N/A                                                                  |

### 3. Set the New default Version

Once verified that the candidate version is on `active LTS` status based on the [Node.js release schedule](https://github.com/nodejs/Release), perform the following:

- Open a [PR](https://github.com/paketo-buildpacks/node-engine/pull/1434) on [node-engine](https://github.com/paketo-buildpacks/node-engine) and bump it as a major release, based on the [Semantic Versioning RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0029-semantic-versioning.md) and publish a release
- Open a [PRs](https://github.com/paketo-buildpacks/ubi-9-base-images/pull/30) on each UBI base images repositories to update the default Node.js version.

### 4. Update Builders and Composite Buildpacks

In order for the builder to pick the new default Node.js version, first update the `buildpack.toml` of the [Nodejs](https://github.com/paketo-buildpacks/nodejs) buildpack to get the latest buildpack and extnsion releases from the Paketo Node.js Buildpacks, do a release and update the builders to pick up the latest version of the Node.js Buildpack.

## Unresolved Questions and Bikeshedding

N/A
