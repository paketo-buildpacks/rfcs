# Buildpack Dependency Management Improvement Overview RFC

## Proposal

This RFC proposes a three-phased approach to move away from the current
dependency management system in the Paketo project and instead standardize on a
new solution that will be more maintainable, extensible, and transparent.

## Motivation

The idea of "dependency management" in this RFC is centered around our process
for retrieving, updating, and providing dependencies in the context of
buildpacks. Dependencies are the distributions that are installed by a
buildpack, such as Golang, Ruby, and Node Engine.  Right now, in many
buildpacks in the Paketo Buildpacks project, the dependencies come from the
[dep-server](https://github.com/paketo-buildpacks/dep-server). Motivation for
this large change is well described in
https://github.com/paketo-community/explorations/issues/8, but in essence,
there are few main issues with the current dep-server model that serve as
motivation for the changes proposed in this RFC:

#### Compilation
Most of the dependencies undergo compilation from source against Ubuntu 18.04,
additional processing occurs in some cases, and then the dependencies are
stored in a bucket to be consumed by automation in the buildpacks. This process
is heavily automated, but will require significant effort if we ever want to
support different operating systems in our Stacks. The compilation code that is
used is also located outside of the Paketo organization, and is difficult to
maintain.

#### Maintenance Scope
This code is also maintained fully by Dependencies maintainers, which is
largely comprised of language-specific scope that would be better suited for
maintenance by language experts. This also makes it hard for language-family
maintainers to fix problems with dependencies themselves, and even harder for
contributors outside of the core development team.

#### Costs
Since all of the dependencies are compiled, every version of every dependency
is stored in an AWS S3 bucket along with their metadata, which eats at project
resources.

#### Inconsistency
The Java buildpacks use a different dependency management system. It would be
great if we followed the same process across the project to simplify choices
down the line.

#### Overall Complexity
The dep-server strategy as a whole, including the workflows, Github actions,
bucket storage, and API endpoint mappings are complicated. A non-trivial part
of the dependency management process occurs outside of Github, requiring
credentials to project AWS and GCP accounts to get full access to everything
involved in keeping our dependencies up to date. This makes it nearly
impossible for non-core development team members to get a full view into how
the project manages dependencies.

## Background: Current Implementation
<details>
<summary> For context, here's how the current implementation works:</summary>

1. Dep-server has a JSON file of `known-versions` for each dependency in GCP.
2. [Get New Versions
   Workflow](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/get-new-versions.yml).
   The dep-server polls for new versions on a timer every hour for every
   dependency. Polling website URIs are hard coded into the dep-server code.
   New versions are discovered by taking the difference between the versions
   the workflow finds and the content of the `known-versions` file.
3. [Build and Upload
   Workflow](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/build-upload.yml).
   The workflow is triggered by the Get New Versions workflow when a new
   version is discovered. The build process in step 3 is delegated to
   [cloudfoundry/buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/tree/384c051f48fdb4b40521daaacc6afaab87da3796/tasks/build-binary-new)
   and
   [cloudfoundry/binary-builder](https://github.com/cloudfoundry/binary-builder/tree/main/recipe)
   and may involve pulling from source, compiling, or processing the dependency
   in some way. The code is written in Ruby.  The compiled dependency is
   uploaded to an S3 bucket. The workflow also gathers metadata (CPEs,
   licenses, SHA256, etc.) about the dependency using dep-server
   dependency-specific code.
4. [Test and Upload
   Workflow](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/templates/test-upload-metadata.yml).
   The workflow is triggered by the Build and Upload workflow and receives the
   metadata from that step. A smoke test is run against the compiled
   dependency, and if successful, the dependency metadata is uploaded to an AWS
   S3 bucket.
5. Endpoint routing for the dep-server is set up through AWS Route 53 and
   Cloudfront to access dependencies and metadata, but the actual dep-server
   runs in Google App Engine.
6. [Update dependencies
   Workflow](https://github.com/paketo-buildpacks/github-config/blob/main/implementation/.github/workflows/update-dependencies.yml).
   Each dependency-providing buildpack has a workflow that runs the `jam
   update-dependencies` command on a timer (or when manually triggered), which
   will update dependency versions from the dep-server depending on
   `[[metadata.dependency-constraints]]` listed in the `buildpack.toml`.
</details>

## Plan Overview

The plan overview provides high level direction for a new dependency management
approach, split into phases that will help to address the concerns cited in
the Motivation section of the RFC. Due to the complex nature of the changes,
the proposals details will be split into separate RFCs.

The new system will focus on shifting all dependency-specific logic into the
buildpacks themselves. Related automation to actually update and build the
dependencies will be generic, so that our Github Actions can simply leverage the
dependency-specific logic in the buildpacks. This allows for buildpack
maintainers to take ownership on where dependencies come from, if and how
they're compiled, and the ability to manage all related automation themselves.
Relatedly, dependencies maintainers will be responsible for setting up general
project-level dependency concerns like automation, best
practices, and maintaining legacy dependencies in the dep-server.

The other focus is to enable Stack flexibility by moving away from supporting
only Ubuntu 18.04 dependencies, which is what we have now due to the way
dependencies are compiled. While some dependencies may still need to be
compiled or processed in some way for optimal buildpack performance, changes to
the dependency retrieval/compilation process should allow for dependencies of
many different OS compatibilities to be used in the buildpack.

In order to implement these features in the buildpacks, there are three main
phases:

1. Federated Model Adoption In Buildpacks: [Phase 1 RFC](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-top-level/text/dependencies/rfcs/0000-dependency-management-overview.md)

Buildpacks will adopt a federated approach to dependency management by moving
the responsibility of dependency-specific logic to buildpacks out of the
dep-server and related repositories.
- Buildpacks maintainers determine if dependencies can be consumed directly from
  upstream or must be compiled or processed in any way
- Dependency-specific bucket is set up for metadata and compiled dependencies
- RFC model is enacted for recording dependency rationale for every dependency
- Remove references to Cloud Foundry compilation code, buildpacks implement
  dependency compilation code (if needed) in Golang
- Version retrieval code is removed from the dep-server repository and moved into Buildpacks
- Dependencies are made available in a manner compatible with a
  variety of stacks

2. Workflow and Action Generalization: [Phase 2
   RFC](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-two/text/dependencies/rfcs/0000-dependency-management-phase-two.md)

All workflows and actions will be moved out of the
[paketo-buildpacks/dep-server](https://github.com/paketo-buildpacks/dep-server/tree/main/.github)
repository and moved into
[paketo-buildpacks/github-config](https://github.com/paketo-buildpacks/github-config)
with ownership by the Tooling team. The actions and workflows be
generalized will leverage code that lives directly alongside the buildpack.
Actions will be simple to run locally as well in the event of Github Actions
degradations.

Automation will be rewritten in a way that all of the dependency update logic
will occur in Github Actions and with files located within the buildpack.

3. Dep-server in Maintenance Mode: [Phase 3
   RFC](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-three/text/dependencies/rfcs/0000-dependency-management-phase-three.md)

With the completion of phase 1 and 2, the dependency management process will be
completely contained within Github Actions, and the dep-server will not be used
as a staging ground for metadata, known versions, and dependencies anymore.
Because of this, the dep-server can be simplified to just continue hosting
legacy dependencies, and will no longer receive updated depenendencies.


## Rationale and Alternatives
The proposed solution attempts to offer the simplest set of changes to address
the main motivations, while also considering the scale of the problem and
estimated time to implement in the buildpacks.

#### `buildpack.toml` dependency removal
An alternative to this plan would be to reconsider the buildpack process of
specifying dependencies in the `buildpack.toml`. Keeping the `buildpack.toml`
up-to-date with new dependency versions and metadata is the reason for all of
the complex automation. If the project instead shifted to a model in which
dependencies/versions are determined during the build, such that the buildpack
searches for available versions from a CDN, generates metadata, and uses it in
the build, most of the need for a complex dependency management system is
eliminated. The buildpacks could also support all versions of a dependency,
rather than a subset. Another benefit would be that buildpack releases would be
dependent of buildpack functionality, rather than dependency bumps.

A big drawback of this alternative is that it's an enormous change to the way
Paketo Buildpacks work today, the scope extends out of dependency management
into buildpack philosphy. Additionally, we lose the ability to test the
dependency functionality outside the build which increases the surface area for
failed builds. Lastly, supporting every dependency version has the potential
for buggy buildpack behaviour, since buildpack logic will have to work for all
N version lines of a dependency.

#### Smallest Possible Change
Another alternative would be to make a more isolated change to the system, by
simply focusing on tackling the issue of stack flexibility within the
dep-server. This option would involve leaving the dep-server repository as is,
and focusing on building extra functionality to use dependencies from upstream
more frequently, and allowing for multiple OS/architecture options. The outcome
would be that everything would stay the same except we'd be able to support
more compatible stacks. This plan would enable more stacks quickly, but has the
major drawback of adding even more technical debt to the dep-server.
