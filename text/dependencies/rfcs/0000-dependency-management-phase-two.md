# Dependency Management Phase 2: Workflow and Github Action Generalization RFC

## Proposal

The process around dependency version discovery, retrieval, possible
compilation, and metadata storage should be carried out through a set of
Dependencies-team maintained Github actions and workflows. The workflows will
leverage dependency-specific code outlined in [RFC 0000: Phase
1](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-one/text/dependencies/rfcs/0000-dependency-management-phase-one.md)
and will live in a common location to be reused across buildacks.

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
- **Update Dependencies**: Runs every hour and runs [`jam
  update-dependencies`](https://github.com/paketo-buildpacks/github-config/blob/f85a65d14fd90f6d63f1af2d408ee38f17ce5c0b/actions/dependency/update/action.yml#L45-L46)
  against the `buildpack.toml`. If there are new versions available in the
  dep-server, this workflow will discover them and open a PR to update the
  `buildpack.toml`.

### New Plan Overview
The new process for managing dependencies will use the `buildpack.toml` as a
source of truth for the latest versions we support, instead of using a separate
`known-versions.json` file. Metadata will also be generated and updated in
place with a pull request to the `buildpack.toml`, rather than being pushed to
an intermediary `metadata.json` file. The overall process will be closer to
what someone would do if they were updating the dependencies themselves, rather
than with automation. The overall steps will be:

1. Pick up all versions of the dependency, using code from the Phase 1 RFC in
   `<buildpack>/dependency/retrieval`
2. Compare the list of all versions with the version constraints and supported
  versions in the `buildpack.toml` to determine what versions can be updated.
3. Generate metadata for each of the versions to be added using code from Phase
   1 in `<buildpack>/dependency/metadata`.
4. If the `URI` and `SHA256` are missing from the metadata, the code will be
  compiled with the code from `<buildpack>/dependency/compilation`.
5. Test the dependency (whether compiled or not) using the test from
   `<buildpack>/dependency/test`
6. (If compiled) Upload the dependency to the dependency GCP bucket
7. (If compiled) Add the GCP bucket access URI and the SHA256 of the dependency to the
    metadta `URI` and `SHA256` fields
8. Update the `buildpack.toml` with the new versions and metadata

This new plan eliminates extra steps of storing metadata in a file for later
use, and then separately updating the dependencies on a timer.

### Workflows and Actions
Pending the Phase 1 RFC is accepted, and it's decided dependency logic will
live alongside the buildpack, workflows will be rolled out to all of the
buildpacks from
[paketo-buildpacks/github-config](https://github.com/paketo-buildpacks/github-config)
inside the `implementation/.github/workflows` location.

Actions will live in the github-config repository as well, under a
directory named `dependency`, inside of the `actions` directory.

The github-config repository `CODEOWNERS` file will be updated to set the
`@paketo-buildpacks/dependencies-maintainers` to the owners of the
`actions/dependency` and `implementation/.github/workflows/<all
dependency-related workflows>`.


Each of the step s outlined in the overview will be converted into workflow
steps.

Workflow 1:
1. Picking up new versions with buildpack code will be a workflow step, which
   runs on a timer at least once per day.

2. Figuring out which versions will be added to the `buildpack.toml` will be
   rolled into an action that outputs versions. It will leverage parts of the
   existing `jam update-dependencies` logic.

3. For individual versions, a Github Actions [`matrix
   strategy`](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#using-a-matrix-strategy)
   will be used to iterate over each version to be added, to generate metadata
   using the code from within the buildpacks.

   The metadata generation code from the buildpack will contain logic to spit
   out "variants" for each dependency version, depending on the stacks
   (OS/architectures) supported by the buildpack.

   For example, if the dependency is used from source but has two different
   artifacts for ARM64 and AMD64 variants, and the buildpack supports both
   architectures, then the metadata generation code should spit out two batches of
   metadata for each new version. One with the AMD64 upstream source URI/SHA256, and
   the other with the ARM64 upstream URI/source SHA256.

5. In the same matrix loop, dependency compilation will be kicked off with the
   code from the buildpacks on the basis of whether the metadata contains the
   `SHA256` and `URI` of the dependency.

6. A smoke test will be run against the dependency in both the
   compiled/non-compiled cases via a step that simply runs the test from
   `<buildpack>/dependency/test`.

7. (If compiled) The dependency will be uploaded via an action

8. (If compiled) The metadata is updated with the SHA256 and GCP bucket URI in
   a workflow step

9. Updating the `buildpack.toml` with the new versions and metadata will also
   be delegated to a new action

10. A pull request will be opened with the changes to the `buildpack.toml`. The
    usual suite of integration and unit tests will be run against the pull
    request as in all other cases.


### Updating Dependencies Manually
All of these steps will run as a workflow with the option for a manual
dispatch, but can be run easily manually on a local system.  Additionally, we
could eventually create a script inside of the `<buildpack>/scripts` directory
to perform the main steps of the `buildpack.toml` update process locally. This
will replace the need for the `jam update-dependencies` command that the
automation uses currently. Since dependency-related logic will live alongside
the buildpack, it makes more sense for manual dependency-update scripts to live
there as well in order to leverage code.


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
and expanding it to work for dependency variants (for different stacks). The
metadata, known versions, and compiled dependencies would still be pushed to
buckets. The only advantage of this strategy is that there's potentially less
code change needed.

A final alternative would be to deviate from using Github Actions, since there
are sometimes issues with high-volume jobs and outages. This option has the
distinct disadvantage of deviating from the process used in the rest of the
project, which would proliferate the concerns around maintainability and
visibilty and would require quite a bit of overhead to set up a new system.

## Unresolved Questions and Bikeshedding (Optional)
- Will running all the steps in one workflow make it difficult to isolate
  failures?
