# Dependency Management Phase 1: Adopting Federated Model RFC

## Proposal

The buildpacks should adopt a federated dependency management strategy. This
will involve all of the buildpacks that provide depdendencies (such as the [Go
Dist CNB](https://github.com/paketo-buildpacks/go-dist) or the [MRI
CNB](https://github.com/paketo-buildpacks/mri)) becoming the owners of
dependency-specific logic that currently resides in the
[dep-server](https://github.com/paketo-buildpacks/dep-server). This includes
code for discovering new versions, retrieving dependencies, and compiling the
dependencies. As a result, maintainers will make/maintain dependency-related
decisions for the dependencies of relevant buildpacks.  Additionally,
buildpacks should use dependencies directly from upstream hosting (source or
binary) whenever possible, to cut down on the number of dependencies that are
uncessarily compiled from source.

## Motivation

Per top-level [RFC
0000](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-top-level/text/dependencies/rfcs/0000-dependency-management-overview.md),
the current dependency management system employed
in the project leads to a number of painpoints, predominantly around
maintainability for Dependencies maintainers, and lack of extensibility by
compiling dependencies for Ubuntu 18.04. In order to ensure the Paketo
Buildpacks project can continue to grow and introduce new buildpacks,
dependencies, and stacks, business logic that pertains to specific dependencies
should be the responsibility of the relevant buildpack.

## Detailed Explanation

The outlined proposal contains a number of changes to the current system which
should be standardized in order to fit together with generalized Github Actions
workflows down the line.

### Background
Dependency-specific logic lives in a few different places today:
- Version discovery code comes from [dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency)
- Source URI to pull dependency source comes from [dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency)
- Compilation code comes from
  [cloudfoundry/buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/blob/master/tasks/build-binary-new/builder.rb)
  and
  [cloudfoundry/binary-builder](https://github.com/cloudfoundry/binary-builder/tree/main/recipe).
- Workflows to run all aspects of dependency retrieval, compilation, uploading
  to buckets all occur in the [dep-server Github
  Actions](https://github.com/paketo-buildpacks/dep-server/actions)
- Known versions of the dependency come from a JSON file inside of a GCP Bucket

All of these components come together outside of the buildpack within
dep-server automation, and then the dependencies themselves are updated inside
of the buildpacks by a separate [Update Dependencies
workflow](https://github.com/paketo-buildpacks/github-config/blob/main/implementation/.github/workflows/update-dependencies.yml),
which bumps versions in the `buildpack.toml` of a buildpack when a new version
has come out.

### Issues to Address
The main issues addressed by this RFC are related to maintainability,
dependency compilation, and code usability.

1. **Maintainability**. Buildpacks maintainers cannot easily fix issues with
   dependencies if they are wrongly compiled or corrupt, since the code is
   under the jurisdiction of the Dependencies team and mostly runs in
   automation. The relevant automation cannot be run in Github Actions for
   debugging unless a user is a Dependencies contributor, which is an added
   blocker. Additionally, compilation code lives in a separate organization
   entirely, and is written in Ruby, despite the rest of the project being
   written in Golang. It's very difficult for outside contributors to
   contribute to dependency code or make fixes with the current set up. It's
   also challenging for general Dependencies maintainers to make
   language-specific choices about dependencies.

2. **Compilation**. Almost every dependency is compiled from source, or has
   some kind of processing for simple installation in the buildpack build
   process. Dependencies are compiled against Ubuntu 18.04 which means the
   dependencies are not necessarily compatible with other Stacks. This means
   the related buildpacks are locked to running on Ubuntu 18.04 based stacks
   only. Since dependencies are compiled, they are stored in an S3 bucket which
   is costly for an ever-expanding set of dependencies and versions.

3. **Usability**. The current system is difficult to run outside of our
   automation, especially the dependency compilation code. When compilation
   code has to change for a new dependency version, it's very challenging to
   use the code locally to test changes. Similarly, the workflows that run in
   the dep-server are not intuitve to use locally. All of the dependency
   management process should ideally able to run locally with ease, in the
   event of Github Actions outages.

### Overarching Plan

The various parts of the dependency management process can be distilled into a
few high-level jobs: (1) new version retrieval, (2) metadata gathering, (3)
compilation, (4) dependency testing, and a very important new addition is (5),
performing these steps such that dependencies are compatible with different
stacks/operating systems/architectures. All 5 of these steps require different
solutions depending on the dependency, which is why they will become the
responsibility of the **buildpack author/maintainer**.

Buildpack authors will be responsible for creating code to perform each of
these steps, which will live in a new buildpack directory called
`dependency`. It will be the job of generalized workflows, actions, and tooling
to orchestrate these steps in an automated fashion, to keep the
`buildpack.toml` up-to-date with new dependency versions.

In order to run the steps in a generalized workflow, each step will need to
conform to a standardized set of inputs and outputs. Each can be written in any
language, but should have a simple way to be executed via a Makefile so it can
be called in a consistent manner. A `Makefile` will be created with targets for
each step, with each step being a bash script in this example:

`<buildpack>/dependency/Makefile`:
```
retrieve:
	@./retrieval/retrieve.sh $(buildpackTomlPath) $(output)
compile:
	@./compilation/compile.sh $(version) $(outputDir) $(target)
test:
	@./test/test.sh $(tarballName) $(version)
```

#### 1. Version Retrieval (`make retrieve`)
  * Description: Discovers dependency versions newer than `buildpack.toml`
    versions (within constraints) and returns each with a set of generated
    metadata in the form of a `metadata.json` file.
  * Inputs:
    * `buildpackTomlPath`  - the path to the  `buildpack.toml` file
    * `output` - the path to a file into which an output metadata JSON will be
      written
  * Outputs:
    * `output` - a `metadata.json` file containing entries for each new version
      discovered at the `output` path.

#### 2. Compilation (`make compile`)
  * Description: Compiles a specific version of the dependency to the target
    platform. Optional for dependencies that need it [Dependencies Directly
    From
    Upstream](https://github.com/paketo-buildpacks/rfcs/blob/cb117e4f45d2bc4e8d7551667100b5c8b9d7e89b/text/dependencies/rfcs/0000-dependency-management-phase-one.md#dependencies-directly-from-upstream)
    section for more information. The future workflow that uses this code will
    ensure that `outputDir` will exist and be writeable. For running locally,
    this should be done by the user.
  * Inputs:
    * `version`  - the specific version to compile
    * `outputDir` - the relative or absolute directory path for the output
      tarball and other artifacts
    * `target` - the target platform variant, which will only be used to
      descriptively name the output artifact.
  * Outputs:
    The following files should be made available in the `outputDir`:
    * Dependency artifact - There should be exactly one tarball, with a name of
      `${dependency}-<description>.tgz`, where <description> can be any
      combination of OS, architecture, target platform, version, etc that the
      buildpack author desires. The dependency name will be highly dependent on
      if the dependency needs to be compiled separately for different
      OS/architecture combinations.
    * Artifact SHASUM -  A file with the same name as the dependency artifact,
      with a `sha256` suffix, containing the SHA256 of the compiled dependency.

#### 3. Test Dependency (`make test`)
  * Description: Performs some verification that the dependency is correctly
    built and functions as expected. Optional for dependencies that have not
    been compiled or processed.
  * Inputs:
    * `tarballPath` - the location of the tarball to test
    * `version` - the dependency version

### Transfer/Combine Version Retrieval and Metadata Generation

The new  version retrieval code will merge together the job of discovering
versions and getting metadata for each version. It will pick up newer versions
than what the `buildpack.toml` contains, and outputs JSON-formatted metadata
for each dependency. This code should be ported from the dep-server repository
to the buildpack under a directory named `dependency/retrieval`, taking in the
path to the `buildpack.toml` file and the path to the output file. It should be
well-documented and useable on a local environment. The location must be
standardized for use in automation.

Buildpack authors should feel free to reuse (or rewrite) the code from the
dep-server for these parts as they see fit. The language that it is written in is
up to maintainers; however, if written in Go it will be easier to leverage
future abstraction libraries that may arise.

Version discovery code comes from
[dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency).
Each dependency has a slightly different way new versions are made
discoverable. The code will use the `buildpack.toml` dependency constraint
metadata and versions in the `buildpack.toml` already to determine new
versions.

Metadata generation code also comes from
[dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency).
Code to generate/gather all of the metadata for a dependency should be moved and combined
into the retrieval code.  The code should
do essentially the same thing that the existent code does, and support the same
metadata fields.
The supported metadata fields are: `source URI`, `source SHA256`, `version`,
`URI`, `SHA256`, `ReleaseDate`, `DeprecationDate`, `stacks`, `purl`, `licenses`
and `CPE`.

#### Caveat: Compiled Dependencies
In the case that the dependencies need to be compiled or processed, the
metadata generation code should omit the `URI` and the `SHA256` from the
metadata. This will be used in automation (described in detail in a subsequent
RFC) to let the dependency management system to trigger compilation of the
dependency. When the dependency is compiled and uploaded to a bucket, the
bucket URI will be the URI in the metadata, and the compiled dependency SHA256
will be the SHA256 in the metadata.

#### Support Multiple Stacks
The metadata generation portion of the code should also be smart enough to spit out
multiple sets of metadata per version if there are multiple variants of a
version from different upstream URIs. For each version that metadata is
generated for, it should handle any/all permutations of dependencies and
stacks.

For example, if separate dependencies are avaiable from a CDN for Ubuntu 18.04
and 22.04, and the buildpack supports both, then the metadata generation could
should produce two batches of metadata for each version, one for each
distribution.

#### New Repository
Eventually, commonalities in version retrieval code (and other parts of the
dependency process) will be able to be abstracted out into a separate code base
so that implementations can be standardized (if written in Golang). The
repository for shared dependency code will live in the Paketo Buildpacks Github
org and will be named `libdependency`.

### Use Dependencies Directly From Upstream
When possible, dependencies should be used directly from their upstream source,
rather than undergoing any additional compilation or modifications performed by
Paketo-maintained code.  For each dependency, the corresponding buildpack
maintainer group will decide if the dependency can be used diretly from
upstream, and must identify the location from which the dependency will be
pulled from.

Some of the Paketo Java buildpacks perform directory stripping during the
buildpack build process itself. This could be a viable alternative to
performing directory modifications during the dependency management process for
maintainers to consider.

All decisions within in a language family should be documented in an RFC.
Rationale should be given for dependencies that we would like to continue
compiling or processing. Maintainers should also consider the ramifications of
their decision in the ability to support "offline" buildpacks that have the
dependency vendored in, if that's a use case supported by the buildpack.

Below are the lists of dependencies the dep-server currently supports, the
source URI, if it is compiled or processed in any way, and where in the code
this behaviour lives now.

<details>
<summary>Dependency list:</summary>

| Name              | Source                                                    | Compiled? And where to find  related code|
| ----------------- | --------------------------------------------------------- | ---------------------------------------- |
| bundler           | https://rubygems.org/downloads/                           | yes, binary-builder                      |
| composer          | https://getcomposer.org/download                          | no, buildpacks-ci                        |
| curl              | https://curl.se/download                                  | yes, buildpacks-ci                       |
| dotnet-aspnetcore | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| dotnet-runtime    | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| dotnet-sdk        | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| go                | https://dl.google.com/go/                                 | yes, binary-builder                      |
| httpd             | http://archive.apache.org/dist/httpd                      | yes, binary-builder                      |
| icu               | https://github.com/unicode-org/icu/releases/download/     | yes, buildpacks-ci                       |
| nginx             | http://nginx.org/download/                                | yes, both locations?                     |
| node              | https://nodejs.org/dist/                                  | yes, binary-builder                      |
| php               | https://www.php.net/distributions/                        | yes, binary-builder                      |
| pip               | https://files.pythonhosted.org/packages                   | yes, with other pip deps buildpacks-ci   |
| pipenv            | https://files.pythonhosted.org/packages                   | yes, with other pip deps buildpacks-ci   |
| python            | https://www.python.org/ftp/python                         | yes, buildpacks-ci                       |
| poetry            | https://files.pythonhosted.org/packages                   | processed, buildpacks-ci                 |
| ruby              | https://cache.ruby-lang.org/pub/ruby                      | yes, binary-builder                      |
| rust              | https://static.rust-lang.org/dist/                        | yes, buildpacks-ci                       |
| tini              | https://github.com/krallin/tini/tarball                   | yes, buildpacks-ci                       |
| yarn              | https://github.com/yarnpkg/yarn/releases/download/v1.15.2 | processed, buildpacks-ci                 |
</details>

### Transfer Compilation Code

For any dependencies that must still be compiled or processed in some way, the
code from the Cloud Foundry repositories should be rewritten, and moved over to
the buildpack under a directory called `dependency/compilation`. The code
should be easily runnable from a local machine to compile the code, and should
be documented with a README about how to use it. As outlined in the
[Overarching
Plan](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-step-one/text/dependencies/rfcs/0000-dependency-management-phase-one.md#overarching-plan)
section, it will take in the `version`, the `outputDir` to put the dependency,
and the `target` image to compile against.

The code will eventually be used in a Github Actions workflow, so the location,
inputs, and outputs needs to be standardized across buildpacks. The workflows
and Github Actions to use this code will be enumerated in a separate RFC.

The dependency will likely need to be compiled against different
stacks/architectures, so this should also be enumerated in the RFC and taken
account of in the new compilation code. This should include information about
the different images we will need to compile against, as well as the stacks
that will be compatible with that dependency. Maintainers should also consider
if the dependency of interest is OS distribution-agnostic, or if it will need
to be compiled separately depending on the distribution or platform it's used
on.

##### Specifiy variants with the `targets.json` file
A file under the path `<buildpack>/dependency/targets.json` will be an
enumeration of the different variants of a dependency, based on the different
stacks the buildpack supports. This will be parsed and used by workflows
described in Phase 2, but also serves as a manifest of the different version
variants of each dependency.
```
[
  {
    "target": <generic name of the group, to be used in tarball naming if compiled>,
    "image": <image to compile against>,
    "stacks": [ <list of compatible stacks>]
  },
  ...
]
```

The images listed in the `target.json` file will directly be used as the image
used during the compilation step during Github Action runs. When compiling a
dependency locally, users should be able to pull the image themselves and run
the compilation code on the container.

### Image Preparation
In the event that a dependency is compiled as outlined in the section above,
the compilation will take place on a Docker image of the buildpack maintainers'
choosing. Hopefully, the image that will be used will contain everything needed
for compilation (as is the case with the Paketo Full Stack build image, which
is used for compilation now so that no modifications are needed). In the event
that the image used for compilation doesn't have everything it needs,
maintainers can provde an optional preparation script inside of
`<buildpack>/dependency/prepare.sh` to install any helper packages. The
preparation steps will differ depending on the image and the dependency
compilation process.

### Bucket Setup

The new dependency management automation (described in a subsequent RFC) will
rely on the `buildpack.toml` and dependency-specific code as the source of
truth for the latest metadata and known versions. This will lead to greater
transparency and discoverability in how we update dependencies.

Since metadata and known versions won't be stored data anymore, a storage
mechanism will only be needed to store dependencies that have been compiled or
processed in some way, and made available for download. For these cases, a
dependency-specific bucket set up to store data will be set up.

### Remove Known Versions

As mentioned above, dependency workflows will use the `buildpack.toml` as a
source of the latest versions we support. Because of this change, we will no
longer need to keep track of all known versions in a separate file. The Phase 2
RFC outlines the workflows to use the `buildpack.toml` to track the latest
versions in the buildpacks, in order to retrieve version updates.

### Smoke Test
In the dep-server, a smoke test is run against every dependency before the
metadata is uploaded during the Github Actions process.

For all dependencies (compiled or not), a similar dependency smoke test should
be added to the buildpack that will eventually be used in the dependency
workflows. It should reside inside the buildpack in a directory called
`/dependency/test` and takes in the path to the dependency tarball and it's
version. For dependencies that are not compiled, maintainers can decide how
rigorous (or not) the test should be.

### New Buildpack Directory Contents

In sum, relevant buildpacks will have the following directory and file
additions:
```
buildpack
└───dependency/
│   └───compilation/
│   │   │   ...
│   └───retrieval/
│   │   │   ...
│   └───test/
│   │   │   ...
│   └───Makefile
│   └───targets.json
│   └───prepare.sh (optional)
```

### Rationale and Alternatives
The main rationale for these changes is ease of contribution, ease of
maintenance, and ease of use. Contribution is easier when the code is grouped
in a logical way, which is acheived by locating dependency-specific code
alongside the buildpack it's used in. Maintenance is easier when codeowners are
the people with the most context on the use cases within the buildpack. Many of
the key pieces of code will still exist, just in a different location, like
metadata collection code and version retrieval code with the caveat that
they're well documented and easy to use outside of our automation. It will be
the job of workflows and Github Actions, maintained by the Dependencies team,
to bring the code together to run in an automated and uniform way. The details
of the automation will be outlined in a subsequent RFC.

An alternative to this proposal would be to make the same changes as outlined,
but to move them into a separate dependency-specific repository, rather than
adding all of this into the buildpack. The benefit of this approach would be
that the buildpack code base stays simple and focused, and the dependency code
is still under the maintenance of buildpack teams.

Another alternative is to leave all of the code where it is in the dep-server
(except the compilation code which will still need to be brought into the
Paketo organization). Then, language maintainers will be codeowners of certain
codepaths within the repository. This has the significant drawback that the
codebase and related automation will still have to significantly change in
order to support more stacks/architectures. The scope of the dep-server
repository is already large, as it accounts for every dependency in the
project, potentially making it hard to contribute and maintain.

## Unresolved Questions and Bikeshedding (Optional)
- Who is going to pay for the buckets?
