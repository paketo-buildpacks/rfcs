# Dependency Management Phase 2: Workflow and Github Action Generalization RFC

## Proposal

The process around dependency version discovery, retrieval, possible
compilation, and metadata storage should be carried out through a set of
Tooling-team maintained Github actions and workflows. The workflows will
leverage dependency-specific code outlined in [RFC 0000: Phase
1](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-one/text/dependencies/rfcs/0000-dependency-management-phase-one.md)
and will live in a common location to be reused across buildacks.

The automation outlined in this RFC is designed to keep some "source of truth"
for the latest supported dependency versions and metadata up to date. If the
"source of truth" for dependency versions and metadata eventually changes in
the project from the `buildpack.toml`, the details of this RFC can still be
applied to keeping that new location updated.

## Motivation

Per top-level [RFC 0000:
Overview](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-top-level/text/dependencies/rfcs/0000-dependency-management-overview.md),
the second phase of the dependency management process update will be to
completely rework the existing set of actions and workflows from the
[dep-server](https://github.com/paketo-buildpacks/dep-server) such that the
dep-server is no longer need because the entire process runs alongside the
buildpacks.

This phase will address concerns around the opaque complexity of the dep-server
process. Additionally, it addresses the painpoint of maintainability.
Dependencies maintainers will own the new workflows and actions, ensuring every
relevant buildpack follows the same overall system architecture, while giving
buildpacks maintainers freedom to make dependency-specific choices separately
and debug issues with full authority.

The new actions will also be simple to run locally in the event of
Github Actions degradations, making the dependency-management system more
flexible in use and transparent in process.

## Detailed Explanation

### Background
For context, here is an enumeration of the current workflows that run in Github
Actions within the dep-server repository.

Each dependency has three main workflows:
- [**Get New
  Versions**](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/get-new-versions.yml):
  discover new versions of the dependency by cross checking published versions
  against a known-versions file on a timer and trigger `Build and Upload`
  workflow when a new version is discovered.

- [**Build and
  Upload**](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/build-upload.yml):
  each new dependency version is compiled or modified from it's upstream
  source, uploaded to an S3 bucket, and the dependency metadata is gathered and
  used to trigger the `Test and Upload` workflow.

- [**Test and Upload
  Metadata**](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/test-upload-metadata.yml):
  runs tests against the compiled dependency and uploads dependency metadata to
  S3 bucket if tests pass.

Metadata and the dependencies themselves are stored in S3 buckets and are
accessible through `https://api.deps.paketo.io/v1/dependency?name=<dependency>`
through a series of API endpoint routing.

Dependencies are updated in the buildpacks in a workflow that runs
in the buildpack's Github Actions:
- **Update Dependencies**: Runs on a timer (every hour is the suggested
  interval to prevent GHA slow downs while also polling regularly, but it is up to
  maintainer discretion) and runs [`jam
  update-dependencies`](https://github.com/paketo-buildpacks/github-config/blob/f85a65d14fd90f6d63f1af2d408ee38f17ce5c0b/actions/dependency/update/action.yml#L45-L46)
  against the `buildpack.toml`. If there are new versions available in the
  dep-server, this workflow will discover them and open a PR to update the
  `buildpack.toml`.

### New Plan Overview

Overall, the workflows for dependency management will heavily rely on the
buildpack-specific steps laid out in Phase 1, and will focus on orchestrating
the steps together in a flexible manner for different potential dependency
options. The different "options" refer to dependencies that either come from
upstream directly or must be compiled/modified, and then whether
multiple variants for different OS/architecture combinations are needed.

The new process for managing dependencies features the `buildpack.toml` as the
"source of truth" for the latest versions we support and related metadata,
instead of using a separate `known-versions.json` file. As mentioned in the
Proposal section, if the location where metadata and versions are stored
changes, the outlined steps can be applied for keeping the new location up to
date as well.  Metadata will be generated and added to this location (the
`buildpack.toml`) all in one workflow, rather than being pushed to an
intermediary `metadata.json` file and being added in a separate workflow. The
overall process will be closer to what someone would do if they were updating
the dependencies themselves, rather than with automation.

The outlined steps below are an overarching guideline for how the process will
work as a single workflow:

1. On a timer or by workflow dispatch, retrieve new versions and related
   metadata using dependency-specfic code from Phase 1 via `make retrieve`.
   This will output a set of metadata for as many new versions exist within
   `buildpack.toml` version constraints. For each new version, multiple
   metadata entries may exist representing different OS target groups. If a
   separate dependency is needed to run on different stacks, this will be
   enumarated as separate metadata entries.
2. For each metadata entry, if the `SHA256` and `URI` metadata fields are
   empty, trigger compilation. This will likely be achieved by using a Github
   Actions [`matrix
   strategy`](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#using-a-matrix-strategy)
3. Dependency compilation as a job takes in the dependency version and the
   target name from the `metadata.json`, and will perform set up and then
   run compilation via the compilation action [outlined in Phase
   1](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-one/text/dependencies/rfcs/0000-dependency-management-phase-one.md#compilation-action).
4. The dependency is tested using the test from dependency-specific tests from
   Phase 1, via `make test`. If the dependency is not compiled, it is at the
   buildpack maintainer's discretion whether it needs to be tested. All
   compiled dependencies will be tested.
6. (If compiled) Upload the dependency to the dependency bucket
7. (If compiled) The dependency `SHA256` and the bucket `URI` are added to metadata
8. An "Assemble" step will run, taking in metadata, the dependencies, and will
   update the `buildpack.toml` file with the new versions and metadata.  The
   step will pass these inputs into a stripped-down version of the `jam
   update-dependencies` command.
9. A pull request is opened in the build repository if an update has occurred.

This new plan eliminates extra steps of storing metadata in a file for later
use, and then separately updating the dependencies on a timer.

### Organization
Pending the Phase 1 RFC is accepted, and it's decided dependency logic will
live alongside the buildpack, workflows will be rolled out to all of the
buildpacks from
[paketo-buildpacks/github-config](https://github.com/paketo-buildpacks/github-config)
inside the `implementation/.github/workflows` location.

Any generic actions that are created will live in the github-config repository
as well, under a directory named `dependency`, inside of the `actions`
directory.

The github-config repository `CODEOWNERS` file will be updated to set the
`@paketo-buildpacks/tooling-maintainers` to the owners of the
`actions/dependency` and `implementation/.github/workflows/<all
dependency-related workflows>`.

### Updating Dependencies Manually
All of these steps will run as a workflow with the option for a manual
dispatch, but can be run easily manually on a local system. Running the steps
manually will be thoroughly documented. The `jam update-dependencies` command
will be stripped down to perform the `buildpack.toml` metadata update process. 

### `buildpack.toml` Updates
When a buildpack supports multiple stacks that require different dependency
variants, the `buildpack.toml` will contain multiple entries for each
dependency version, for each variant. For example's sake only, if the `bundler`
dependency is compiled, and had two variants, an `ubuntu`-compatible version
and a `windows`-compatible version, the `buildpack.toml` entry for a version
would have two entries per version:
```
 [[metadata.dependencies]]
    cpe = "cpe:2.3:a:bundler:bundler:2.3.15:*:*:*:*:ruby:*:*"
    id = "bundler"
    licenses = ["MIT", "MIT-0"]
    name = "Bundler"
    purl = "pkg:generic/bundler@2.3.15?checksum=05b7a8a409982c5d336371dee433e905ff708596f332e5ef0379559b6968431d&download_url=https://rubygems.org/downloads/bundler-2.3.15.gem"
    sha256 = "some-sha"
    source = "https://rubygems.org/downloads/bundler-2.3.15.gem"
    source_sha256 = "05b7a8a409982c5d336371dee433e905ff708596f332e5ef0379559b6968431d"
    stacks = ["io.buildpacks.stacks.bionic", "io.buildpacks.stacks.jammy"]
    uri = "some-GCP-bucket-URI://bundler-2.3.15-ubuntu.tgz"
    version = "2.3.15"

 [[metadata.dependencies]]
    cpe = "cpe:2.3:a:bundler:bundler:2.3.15:*:*:*:*:ruby:*:*"
    id = "bundler"
    licenses = ["MIT", "MIT-0"]
    name = "Bundler"
    purl = "pkg:generic/bundler@2.3.15?checksum=05b7a8a409982c5d336371dee433e905ff708596f332e5ef0379559b6968431d&download_url=https://rubygems.org/downloads/bundler-2.3.15.gem"
    sha256 = "some-sha"
    source = "https://rubygems.org/downloads/bundler-2.3.15.gem"
    source_sha256 = "05b7a8a409982c5d336371dee433e905ff708596f332e5ef0379559b6968431d"
    stacks = ["some-windows-stack"]
    uri = "some-GCP-bucket-URI://bundler-2.3.15-windows.tgz"
    version = "2.3.15"
```

The `buildpack.toml` will have multiple variant entries for every version, and
there will be more variants as the buildpack supports more stacks. Variants
differ by `URI`, `SHA256`, and `stacks`. In order to control increasing
`buildpack.toml` complexity and duplication, some method to abstract duplicated
fields might be helpful, and can be introduced in a separate RFC.

### Rationale and Alternatives

As stated above, this proposal makes almost all of the process available
directly in Github Actions. This makes the dependency management process much
more visible to everyone, since dependencies, metadata, and versions aren't
behind a credential-protected bucket. It will also heavily lean on code
maintained by buildpacks maintainers to give the needed flexibility for all of
the dependencies. The pull request model works well with the current process
used in Paketo.

An alternative to this proposal would be to keep more of the existent
infrastructure in place, such as keeping the `jam update-dependencies` command
as it currently exists, and expanding it to work for dependency variants (for
different stacks). The metadata, known versions, and compiled dependencies
would still be pushed to buckets. The only advantage of this strategy is that
there's potentially less code change needed.

A final alternative would be to deviate from using Github Actions, since there
are sometimes issues with high-volume jobs and outages. This option has the
distinct disadvantage of deviating from the process used in the rest of the
project, which would proliferate the concerns around maintainability and
visibilty and would require quite a bit of overhead to set up a new system.

## Unresolved Questions and Bikeshedding (Optional)
- Will running all the steps in one workflow make it difficult to isolate
  failures?
- Should we introduce a mechanism to perform the workflow for a single input
  version?
