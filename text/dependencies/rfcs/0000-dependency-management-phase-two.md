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
[dep-server](https://github.com/paketo-buildpacks/dep-server).

This phase of dependency management update is focused on addressing the
painpoint of maintainability. Dependencies maintainers will own the new
workflows and actions, ensuring every relevant buildpack follows the same
overall system architecture, while giving buildpacks maintainers freedom to make
dependency-specific choices separately and debug issues with full authority.

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

### New Plan
The new set of workflows will closely mirror the existing set of workflows with
some modifications.  Workflows will still be responsible for getting new
versions, pulling dependencies from a URI, optionally compiling them, testing
them, and then publishing metadata.

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

### New Workflows and Actions
This section explains on a high level how the new workflows and associated
actions will work. The implementation details may be subject to slight change,
but the overall structure and main components of the automation should stay consistent
with what's in this proposal.

1. **Get New Versions**

   Description: This workflow will be extremely similar to the current `Get New
   Versions` worklow.

   Workflow:
   * Runs twice per day
   * Needs access to the `known-versions.json` file from GCP (see Phase 1 RFC)
   * Will leverage a `Retrieve Versions` action outlined below
   * Updates the `known-versions.json` file with newly discovered versions
   * Trigger build workflows for each new version
---

   Action: **Retrieve Versions**

     Inputs:
     * dependency name
     * known versions list
     * version retrieval code from the buildpack under
       `dependency/retrieval`

     Action function:
     * Runs the version retrieval code from the buildpack
     * Compares output versions to the `known-versions.json`
     * Returns a list of new versions
---
2. **Get Dependency and Gather Metadata**

   Description: This workflow has the bulk of the dependency management logic
   to perform compilation, dependency testing, artifact uploading, and metadata
   gathering.

   The `dependency.json` file from the buildpack will define "variants" of
   each dependency. Variants in this context mean dependencies of the same
   version for different OS/architectures. There are two main pathways for this workflow:

   1. Dependencies are used directly from upstream and undergo NO
      post-processing. In this case, "variants" will differ in the `uri` that
      they're pulled from (the AMD64 or ARM64 versions) and will have different
      sets of compatible stacks.

   2. Dependencies are compiled or processed in some way. In this case
      "variants" will likely have the same generic source URI but will differ
      in the image that they are compiled against.

   The workflow should be built to handle both of these scenarios.

   Workflow:
   * Triggered by previous workflow (or by manual trigger) with dependency version

   * [Job 1]: Parse the array of `variants` of the `dependency/dependency.json`
     file from the buildpack and outputs a JSON
     [`matrix`](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#using-a-matrix-strategy).

   * [Job 2]: Needs the matrix output from `Job 1` and will employ a [`matrix`
     `strategy`](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#example-using-a-single-dimension-matrix)
     from the JSON to iterate over each variant.

     The rest of the steps below will run as a part of `Job 2` for each variant:

   * If the variant `compile-against` field from the `dependency.json` is
     set to `use-upstream`:
     * Pull the dependency from the upstream source URI

   * If the variant `compile-against` field from the `dependency.json` is set to
     an image name (instead of `use-upstream`):
     * Dependency must be compiled or modified
     * Run the `Compile or Modify Action` which leverages the dependency
       compilation code from the buildpack under `dependency/compilation`. It
       will likely need to take in the variant `compile-against` image and the source `uri`.
     * The output should be a dependency artifact.
     * As a future direction, if the `compile-against` image requires a
       different architecture (such as ARM64 stack image varieties), the
       workflow will eventually include a step to run compilation in a VM of
       that architecture. This will be fleshed out in a future RFC.

   * Run a smoke test against the dependency artifact, from the buildpack under
     `dependency/test`. Fail the workflow if the test does not pass.
   * If the dependency was compiled/modified, upload the compiled dependency to
     the dependency-specific GCP bucket using the related action
   * Gather metdata about the dependency by leveraging the buildpack dependency
     metadata generation code in the `dependency/metadata` location. The code
     should take the list of compatible stacks for the variant in as an
     argument.
     * For dependencies that did not undergo compilation and are used directly
       from their upstream source, the `uri` and `source_uri` field will be the
       same.
   * Publish metadata by pushing metadata to a `metadata.json` file in the
     dependency-specific GCP bucket.
   * Triggers the `Update Dependencies` workflow

---

   Action: **Compile or Modify Dependency**

     Inputs:
     * dependency name
     * image to compile against
     * upstream URI
     * version (from workflow dispatch)

     Action Function: This action will leverage the dependency
     compilation code from the buildpack under `dependency/compilation` and
     pass it the dependency version and upstream URI. The image to compile
     against is an input, and will be used as the `FROM` image in the action
     Dockerfile.
---

   Action: **Upload Dependency**

     Inputs:
     * dependency archive
     * credentials for GCP Bucket
     * GCP bucket location

     Action Function: If `use-upstream` is false, upload the output from the
     compilation step to the dependency specific GCP bucket

---

   Action: **Upload Metadata**

     Inputs:
     * dependency metadata (name, version, URI, source URI, SHA256, source
       SHA256, stacks, deprecation date, CPE, PURL, licenses)
     * credentials for GCP Bucket
     * GCP bucket location

     Action Function: Add the dependency metadata to the `metadata.json` for the
     dependency and upload it to the dependency-specific GCP bucket

---

3. **Update Dependencies**

   Workflow:
   * Triggered by previous workflow (or by manual trigger)
   * Runs exactly the same way as the current workflow does with `jam
     update-dependencies`, but will be triggered by depenency updates, rather
     than running on a timer.

### Rationale and Alternatives

TODO

## Unresolved Questions and Bikeshedding (Optional)
